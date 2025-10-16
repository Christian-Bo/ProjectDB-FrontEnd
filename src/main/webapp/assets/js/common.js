/* 
 * common.js — utilidades compartidas (v15)
 * - Autodetección robusta de API_BASE (meta -> cache -> location.origin) con sondeo.
 * - ntBuildUrl(path) para convertir rutas relativas en absolutas con la base vigente.
 * - ntGet/ntPost/ntPut/ntDelete toleran rutas relativas o absolutas.
 * - Compatibilidad con API.request/API.toast ya usada en Proveedores.
 * - Manejo de errores Tomcat/HTML con mensajes claros.
 * - Suavizado para catálogos (/api/compras/catalogos/*): ante 500, retorna [] en GET.
 * - Nuevos helpers opcionales: ntGetSafe(), ntGetOrEmpty().
 */

(function(){
  console.debug('[common] loaded v15');

  /* ============================
   * 1) Resolución de API_BASE
   * ============================ */

  // 1.1 Preferencias (sin I/O)
  function preferredBase() {
    try {
      if (window.API_BASE) return String(window.API_BASE).replace(/\/$/, '');
      const m = document.querySelector('meta[name="api-base"]');
      if (m && m.content) return String(m.content).replace(/\/$/, '');
      const cached = localStorage.getItem('nt.apiBase.ok');
      if (cached) return String(cached).replace(/\/$/, '');
    } catch {}
    return location.origin.replace(/\/$/, '');
  }

  // 1.2 Base actual (considera cache si existe)
  function currentBase() {
    const cached = localStorage.getItem('nt.apiBase.ok');
    if (cached) return String(cached).replace(/\/$/,'');
    return preferredBase();
  }

  // 1.3 Setter con saneo + log
  function setApiBase(b) {
    window.API_BASE = String(b || preferredBase()).replace(/\/$/,'');
    console.log('%c[common] API_BASE = ' + window.API_BASE, 'color:#7f5af0');
    return window.API_BASE;
  }

  // 1.4 Sonda de candidatos; memoriza la primera base que responda
  async function probeBaseList(candidates, probePath='/api/compras') {
    const unique = Array.from(new Set((candidates||[]).filter(Boolean))).map(b => String(b).replace(/\/$/,''));
    for (const base of unique) {
      const url = `${base}${probePath}`;
      try {
        const res = await fetch(url, { method:'GET' });
        // Cualquier 2xx-4xx nos sirve para saber que hay servidor vivo
        if (res.ok || (res.status >= 200 && res.status < 500)) {
          localStorage.setItem('nt.apiBase.ok', base);
          setApiBase(base);
          return base;
        }
      } catch(_e) { /* probar siguiente */ }
    }
    return setApiBase(preferredBase());
  }

  // 1.5 API pública para re-sondear cuando quieras
  window.getApiBase    = () => currentBase();
  window.ntPickApiBase = async function(candidates, probePath='/api/compras'){
    return probeBaseList(candidates, probePath);
  };

  // 1.6 Arranque: fija base y lanza sonda no bloqueante
  setApiBase(currentBase());
  (async ()=>{
    const meta   = document.querySelector('meta[name="api-base"]')?.content;
    const cached = localStorage.getItem('nt.apiBase.ok');
    const same   = location.origin;
    await probeBaseList([meta, cached, same]);
  })();


  /* ============================
   * 2) UI helpers (toasts, confirm)
   * ============================ */

  window.ntToast = function ({title='Mensaje', body='', type='info', delay=4500}) {
    const container = document.getElementById('toastStack') || (() => {
      const wrap = document.createElement('div');
      wrap.id = 'toastStack';
      wrap.className = 'toast-container position-fixed top-0 end-0 p-3';
      wrap.style.zIndex = 1080;
      document.body.appendChild(wrap);
      return wrap;
    })();

    const icon = type==='success' ? 'bi-check-circle-fill'
               : type==='error'   ? 'bi-x-circle-fill'
               : type==='warning' ? 'bi-exclamation-triangle-fill'
               : 'bi-info-circle-fill';

    const toast = document.createElement('div');
    toast.className = `toast nt-toast-${type}`;
    toast.innerHTML = `
      <div class="toast-header">
        <i class="bi ${icon} me-2"></i>
        <strong class="me-auto">${title}</strong>
        <button type="button" class="btn-close" data-bs-dismiss="toast" aria-label="Cerrar"></button>
      </div>
      <div class="toast-body">${body}</div>`;
    container.appendChild(toast);
    const bs = new bootstrap.Toast(toast, {delay});
    bs.show();
    toast.addEventListener('hidden.bs.toast', ()=> toast.remove());
  };
  window.showToast = (message, type='info', title='Mensaje') => window.ntToast({ title, body: message, type, delay: 4200 });

  window.ntEsc = s => String(s ?? '').replace(/[&<>"']/g, m=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));

  // Intenta extraer un mensaje útil de respuestas HTML (p.ej. Tomcat 500)
  function extractMessageFromHtml(html) {
    try {
      const tmp = document.implementation.createHTMLDocument('');
      tmp.documentElement.innerHTML = html;
      const t = tmp.querySelector('title')?.textContent?.trim();
      const h1 = tmp.querySelector('h1')?.textContent?.trim();
      // Combina título y H1 si existen
      const joined = [t, h1].filter(Boolean).join(' – ');
      return joined || html.replace(/<[^>]+>/g,' ').replace(/\s+/g,' ').trim().slice(0,180);
    } catch { return html; }
  }

  window.ntParseApiError = (txt) => {
    if (!txt) return 'Error';
    // Si viene JSON
    try { const j=JSON.parse(txt); return j.error||j.message||j.detail||txt; } catch {}
    // Si parece HTML (Tomcat)
    if (/<html[^>]*>/i.test(txt)) return extractMessageFromHtml(txt);
    // Texto plano
    return String(txt).trim();
  };


  /* ==========================================
   * 3) Construcción de URL y fetch JSON robusto
   * ========================================== */

  // Convierte rutas relativas en absolutas usando la base vigente
  window.ntBuildUrl = function(path){
    if (!path) return currentBase();
    if (/^https?:\/\//i.test(path)) return path; // ya es absoluta
    const BASE = currentBase();
    const slash = path.startsWith('/') ? '' : '/';
    return (`${BASE}${slash}${path}`).replace(/([^:]\/)\/+/g, '$1'); // normaliza //
  };

  // Detección de ruta de catálogo de compras
  function isComprasCatalog(url) {
    try {
      const u = new URL(url);
      return /\/api\/compras\/catalogos\//i.test(u.pathname);
    } catch {
      return /\/api\/compras\/catalogos\//i.test(url);
    }
  }

  async function ntFetchJson(method, urlOrPath, body) {
    const url = ntBuildUrl(urlOrPath);
    try{
      const opts = { method, headers: {} };
      if (body !== undefined) { opts.headers['Content-Type'] = 'application/json'; opts.body = JSON.stringify(body); }
      const res = await fetch(url, opts);
      const raw = await res.text();

      if (!res.ok) {
        // Si respuesta es HTML (Tomcat), conviértela a mensaje legible
        const parsed = window.ntParseApiError(raw || `HTTP ${res.status}`);
        // Suavizado específico para CATÁLOGOS: devuelve [] en GET cuando el backend responde 5xx
        if (method === 'GET' && res.status >= 500 && isComprasCatalog(url)) {
          console.warn(`[common] catálogo falló con ${res.status} en ${url}. Devolviendo [] para no romper la UI. Detalle: ${parsed}`);
          return [];
        }
        throw new Error(parsed);
      }
      if (!raw) return null;

      // Intenta JSON; si no, intenta parsear HTML -> mensaje
      try { return JSON.parse(raw); }
      catch { 
        const msg = window.ntParseApiError(raw);
        // Si la ruta es de catálogo y la respuesta no es JSON, regresamos []
        if (method === 'GET' && isComprasCatalog(url)) {
          console.warn(`[common] catálogo no devolvió JSON en ${url}. Devolviendo [].`);
          return [];
        }
        throw new Error(msg);
      }
    }catch(err){
      const isConn = /Failed to fetch|NetworkError|ERR_CONNECTION|TypeError|CORS/i.test(String(err));
      const nice = isConn ? `No se pudo contactar el backend.\nURL: ${url}\nVerifica servidor/URL/CORS.` : err.message;
      // Para catálogos, ante error de red devolvemos [] para mantener UI operativa
      if (method === 'GET' && isComprasCatalog(url)) {
        console.warn(`[common] error de red al cargar catálogo ${url}. Se devuelve []. Error: ${nice}`);
        return [];
      }
      throw new Error(nice);
    }
  }

  // Helpers globales (rutas relativas o absolutas, ambas sirven)
  window.ntGet    = (pathOrUrl)        => ntFetchJson('GET', pathOrUrl);
  window.ntPost   = (pathOrUrl, body)  => ntFetchJson('POST', pathOrUrl, body);
  window.ntPut    = (pathOrUrl, body)  => ntFetchJson('PUT', pathOrUrl, body);
  window.ntDelete = (pathOrUrl)        => ntFetchJson('DELETE', pathOrUrl);

  // ===== Helpers opcionales (no rompen nada existente) =====
  // ntGetSafe: retorna null (o el fallback provisto) si hay error.
  window.ntGetSafe = async function(pathOrUrl, fallback=null){
    try { return await ntGet(pathOrUrl); }
    catch(e){ console.warn('[common] ntGetSafe:', e?.message || e); return fallback; }
  };
  // ntGetOrEmpty: atajo para colecciones; retorna [] si hay error.
  window.ntGetOrEmpty = async function(pathOrUrl){
    const r = await window.ntGetSafe(pathOrUrl, []);
    return Array.isArray(r) ? r : [];
  };


  /* ==============================
   * 4) Compatibilidad: window.API
   * ==============================
   * API.request(path, { method, headers, json, body, userId })
   * API.toast(msg, type)
   */
  window.API = (function () {

    function buildUrl(path) { return window.ntBuildUrl(path); }

    async function request(path, { method = 'GET', headers = {}, json, body, userId = 1 } = {}) {
      const upper = String(method).toUpperCase();
      const url = buildUrl(path);
      const baseHeaders = { 'Accept': 'application/json' };
      if (upper === 'POST' || upper === 'PUT' || upper === 'DELETE') {
        baseHeaders['X-User-Id'] = String(userId);
      }
      if (json !== undefined) baseHeaders['Content-Type'] = 'application/json';

      let res, payload, ct, raw;
      try{
        res = await fetch(url, {
          method: upper,
          mode: 'cors',
          headers: { ...baseHeaders, ...headers },
          body: json !== undefined ? JSON.stringify(json) : body,
        });
        ct  = res.headers.get('content-type') || '';
        raw = await res.text();
        payload = ct.includes('application/json') ? (raw ? JSON.parse(raw) : null) : raw;
      }catch(err){
        const isConn = /Failed to fetch|NetworkError|ERR_CONNECTION|TypeError|CORS/i.test(String(err));
        const nice = isConn ? `No se pudo contactar el backend.\nURL: ${url}` : String(err);
        throw new Error(nice);
      }

      if (!res.ok) {
        const parsed = typeof payload === 'string' ? window.ntParseApiError(payload) : (payload?.message || payload?.error || res.statusText);
        // Igual que en ntFetchJson: suaviza catálogos 5xx en GET
        if (upper === 'GET' && res.status >= 500 && isComprasCatalog(url)) {
          console.warn(`[common/API] catálogo falló con ${res.status} en ${url}. Devolviendo [] para no romper la UI. Detalle: ${parsed}`);
          return [];
        }
        throw new Error(`HTTP ${res.status} – ${parsed}`);
      }
      return payload;
    }

    function toast(msg, type = 'info') { showToast(msg, type); }

    return { request, toast };
  })();

})();
