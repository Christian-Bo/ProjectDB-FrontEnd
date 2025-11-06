/* ==========================================================
 * common.api.js — helpers + parche de fetch con Bearer
 * Seguro frente a doble declaración de API (no usa `const API`)
 * + Fallback inteligente de rutas (ctxPath y /api)
 * ========================================================== */

/* ---------------- API BASE ---------------- */
(function resolveApiBase(){
  const meta = document.querySelector('meta[name="api-base"]');
  const fromMeta = meta?.getAttribute('content')?.trim() || '';
  const fromLS   = localStorage.getItem('api_base') || '';

  // Prioriza localStorage; luego meta; si no, vacío
  window.API_BASE = fromLS || fromMeta || '';

  console.log('[common] API_BASE =', window.API_BASE || '(relativo)');
})();


/* ============= NUEVO: helpers de contexto + fallbacks ============= */
function __ctxPath(){
  try{
    const seg = location.pathname.split('/').filter(Boolean);
    return seg.length > 0 ? ('/' + seg[0]) : '';
  }catch{ return ''; }
}

// Devuelve variantes de URL para reintentos cuando hay 404/500
function __buildFallbackUrls(absUrlStr){
  const urls = [];
  try{
    const u = new URL(absUrlStr, window.location.origin);
    const baseOrigin = u.origin;
    const path = u.pathname;      // ej: /api/inventario/alertas
    const search = u.search || '';
    const ctx = __ctxPath();      // ej: /frontend

    const push = (x) => { if (x && !urls.includes(x)) urls.push(x); };

    // 1) Original primero
    push(u.toString());

    // 2) Con context path
    if (ctx && !path.startsWith(ctx)) push(baseOrigin + ctx + path + search);

    // 3) Asegurar que exista /api
    if (!/\/api(\/|$)/i.test(path)) {
      push(baseOrigin + '/api' + (path.startsWith('/') ? path : '/' + path) + search);
      if (ctx) push(baseOrigin + ctx + '/api' + path + search);
    } else {
      // 4) Quitar /api (por si el back lo expone sin /api)
      push(baseOrigin + path.replace('/api','') + search);
      if (ctx && !path.startsWith(ctx)) push(baseOrigin + ctx + path + search);
      if (ctx) push(baseOrigin + ctx + path.replace('/api','') + search);
    }

    // 5) Si hay API_BASE absoluto diferente al origin, pruébalo
    const apiBase = (window.API_BASE || '').replace(/\/+$/,'');
    if (apiBase && !absUrlStr.startsWith(apiBase)) {
      push(apiBase + path + search);
      if (!/\/api(\/|$)/i.test(path)) push(apiBase + '/api' + path + search);
      if (ctx) {
        push(apiBase + ctx + path + search);
        if (!/\/api(\/|$)/i.test(path)) push(apiBase + ctx + '/api' + path + search);
      }
    }
  }catch(e){
    urls.push(absUrlStr);
  }
  return urls;
}

// Reintenta secuencialmente en variantes cuando 404/500
async function __fetchWithFallback(originalFetch, absUrlStr, init){
  const candidates = __buildFallbackUrls(absUrlStr);
  let lastError = null;

  for (const url of candidates){
    try{
      const res = await originalFetch(url, init);
      if (res.ok) return res;

      // Para 404 o 5xx probamos siguiente
      if (res.status === 404 || (res.status >= 500 && res.status <= 599)) {
        try {
          const txt = await res.clone().text();
          // Si Tomcat devuelve HTML de "No encontrado", seguimos intentando
          if (/No encontrado|No static resource|Estado HTTP 404|HTTP Status 404/i.test(txt)) {
            lastError = new Error(txt || `HTTP ${res.status}`);
            continue;
          }
        } catch {}
        lastError = new Error(`HTTP ${res.status}`);
        continue;
      }

      // Si es otro error (400/401/403, etc.) devolvemos ese directamente
      return res;
    }catch(err){
      lastError = err;
      continue;
    }
  }
  // Nada funcionó
  if (lastError) throw lastError;
  throw new Error('No se pudo resolver el endpoint');
}

/* ---------------- SESIÓN / TOKEN (varias fuentes) ---------------- */
function loadSession() {
  try {
    const raw = localStorage.getItem('nt.session');
    if (raw) {
      const s = JSON.parse(raw);
      if (s && s.token) return s;
    }
  } catch {}

  try {
    if (window.Auth && typeof Auth.load === 'function') {
      const s = Auth.load();
      if (s && s.token) return s;
    }
  } catch {}

  const t = localStorage.getItem('auth_token') || localStorage.getItem('sessionToken');
  if (t) return { token: t };

  return null;
}

/* ---------------- Headers comunes ---------------- */
function buildHeaders(extra = {}) {
  const h = {
    'Accept': 'application/json',
    ...extra
  };

  const s = loadSession();
  if (s?.token) h['Authorization'] = 'Bearer ' + s.token;

  // Compatibilidad con back/BD legacy
  const compatUserId = (window.API && window.API.userId != null) ? window.API.userId : 1;
  h['X-User-Id'] = String(compatUserId);

  return h;
}

/* ---------------- URL absoluta ---------------- */
function __absUrl(pathOrUrl) {
  if (/^https?:\/\//i.test(pathOrUrl)) return pathOrUrl;
  if (pathOrUrl.startsWith('/')) {
    if (window.API_BASE) return window.API_BASE + pathOrUrl;
    return new URL(pathOrUrl, window.location.origin).toString();
  }
  return new URL(pathOrUrl, window.location.origin).toString();
}

/* ---------------- HTTP Helpers base (crudos) ---------------- */
async function apiGet(path, params = {}) {
  const base = (window.API && window.API.baseUrl) ? window.API.baseUrl : '';
  const url = new URL(base + path, window.location.origin);
  Object.entries(params).forEach(([k, v]) => {
    if (v !== undefined && v !== null && v !== '') url.searchParams.append(k, v);
  });
  const res = await fetch(url, { headers: buildHeaders() });
  return handleResponse(res);
}

async function apiSend(method, path, bodyObj) {
  const base = (window.API && window.API.baseUrl) ? window.API.baseUrl : '';
  const res = await fetch(base + path, {
    method,
    headers: buildHeaders({ 'Content-Type': 'application/json' }),
    body: (bodyObj === undefined ? null : JSON.stringify(bodyObj))
  });
  return handleResponse(res);
}

async function apiDelete(path) {
  const base = (window.API && window.API.baseUrl) ? window.API.baseUrl : '';
  const res = await fetch(base + path, {
    method: 'DELETE',
    headers: buildHeaders()
  });
  return handleResponse(res);
}

/* ---------------- Manejo de errores mejorado ---------------- */
function __extractMessageFromHtml(html) {
  try {
    const tmp = document.implementation.createHTMLDocument('');
    tmp.documentElement.innerHTML = html;
    const t = tmp.querySelector('title')?.textContent?.trim();
    const h1 = tmp.querySelector('h1')?.textContent?.trim();
    const joined = [t, h1].filter(Boolean).join(' – ');
    return joined || html.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim().slice(0, 220);
  } catch { return html; }
}

function ntParseApiError(txt) {
  if (!txt) return 'Error';
  try { const j = JSON.parse(txt); return j.detail || j.message || j.error || txt; } catch {}
  if (/<html[^>]*>/i.test(txt)) return __extractMessageFromHtml(txt);
  return String(txt).trim();
}

async function handleResponse(res) {
  const text = await res.text();
  const tryJson = () => { try { return text ? JSON.parse(text) : null; } catch { return null; } };

  if (res.ok) {
    const data = tryJson();
    return (data !== null ? data : text || null);
  }

  if (res.status === 401 || res.status === 403) {
    const s = loadSession();
    if (s?.token) {
      const isLogin = /login\.jsp$/i.test(location.pathname) || /index\.jsp$/i.test(location.pathname);
      if (!isLogin) {
        try { localStorage.removeItem('nt.session'); } catch {}
        try { localStorage.removeItem('auth_token'); localStorage.removeItem('sessionToken'); } catch {}
        showToast('Sesión expirada. Vuelve a iniciar sesión.', 'warning');
        setTimeout(() => { window.location.href = 'index.jsp'; }, 600);
      }
    }
  }

  let msg = text || `HTTP ${res.status}`;
  const j = tryJson();
  if (j) {
    msg = j.detail || j.message || j.error || JSON.stringify(j);
  } else {
    msg = ntParseApiError(text || msg);
  }
  throw new Error(msg);
}

/* ---------------- UI Utils (toasts + helpers) ---------------- */
function showToast(message, level = 'primary') {
  const toastEl = document.getElementById('appToast');
  const msgEl = document.getElementById('toastMsg');
  if (!toastEl || !msgEl || typeof bootstrap === 'undefined') {
    console[level === 'danger' ? 'error' : 'log'](`[${level}] ${message}`);
    return;
  }
  msgEl.textContent = message;
  toastEl.className = `toast align-items-center text-bg-${level} border-0`;
  bootstrap.Toast.getOrCreateInstance(toastEl, { delay: 2800 }).show();
}

function formToObject(formEl) {
  const data = {};
  new FormData(formEl).forEach((v, k) => { data[k] = v; });
  return data;
}

function setValue(id, value) {
  const el = document.getElementById(id);
  if (el) el.value = value ?? '';
}

/* ---------------- Parche global de fetch (inyecta Bearer) ---------------- */
(function patchFetchForAuth(){
  if (!window.fetch) return;
  const originalFetch = window.fetch;
  window.fetch = function(input, init) {
    init = init || {};
    let hdrs = init.headers instanceof Headers ? init.headers : new Headers(init.headers || {});
    if (!hdrs.has('Authorization')) {
      const s = loadSession();
      if (s && s.token) hdrs.set('Authorization', 'Bearer ' + s.token);
    }
    const userId = (window.API && window.API.userId != null) ? window.API.userId : 1;
    if (!hdrs.has('X-User-Id')) hdrs.set('X-User-Id', String(userId));
    if (!hdrs.has('Accept')) hdrs.set('Accept', 'application/json');

    const m = (init.method || 'GET').toUpperCase();
    if ((m === 'POST' || m === 'PUT' || m === 'PATCH') && init.body && typeof init.body === 'object') {
      if (!hdrs.has('Content-Type')) hdrs.set('Content-Type', 'application/json');
      try { init.body = JSON.stringify(init.body); } catch {}
    }

    init.headers = hdrs;

    // DEBUG útil: primer request sensible
    const urlStr = (typeof input === 'string') ? __absUrl(input) : String(input);
    if (typeof urlStr === 'string' && urlStr.includes('/api/proveedores/_empleados')) {
      console.log('[common] Calling', urlStr, 'Authorization:', hdrs.get('Authorization'));
    }

    // =================== NUEVO: fallback automático ===================
    // Intento 1: URL tal cual (absoluta)
    // Si falla con 404/5xx, reintenta variantes con ctx y /api
    try {
      const abs = __absUrl(urlStr);
      return __fetchWithFallback(originalFetch, abs, init);
    } catch (e) {
      // Si algo salió mal en la construcción, intenta el fetch original
      return originalFetch(input, init);
    }
    // ==================================================================
  };
})();

/* =========================================================
 * Polyfills esperados por módulos existentes
 * ========================================================= */
if (typeof window.ntEsc !== 'function') {
  window.ntEsc = function (s) {
    return String(s ?? '').replace(/[&<>"']/g, function(ch){
      return ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[ch]);
    });
  };
}
if (typeof window.ntToast !== 'function') {
  window.ntToast = function (msg, level = 'primary') {
    try { showToast(msg, level); } catch { console.log(`[${level}] ${msg}`); }
  };
}
if (typeof window.ntAlert !== 'function') {
  window.ntAlert = function (msg, level = 'primary') {
    try { showToast(msg, level); } catch { console.log(`[${level}] ${msg}`); }
  };
}
if (typeof window.ntParseApiError !== 'function') {
  window.ntParseApiError = ntParseApiError;
}

/* =========================================================
 * API público global — EXTENSIÓN, no redeclaración
 * (evita conflicto con otros archivos que también definan API)
 * ========================================================= */
(function initGlobalAPI(){
  // Usa el existente o crea uno vacío
  window.API = window.API || {};

  // Base URL: respeta la ya cargada si existe
  if (typeof window.API.baseUrl === 'undefined') {
    window.API.baseUrl = (localStorage.getItem('api_base') || '');
  }
  if (typeof window.API.userId === 'undefined') {
    window.API.userId = 1;
  }

  // Atajos: si ya existen, NO los pisamos
  if (typeof window.API.get !== 'function')    window.API.get    = (path, params = {}) => apiGet(path, params);
  if (typeof window.API.post !== 'function')   window.API.post   = (path, body) => apiSend('POST', path, body);
  if (typeof window.API.put !== 'function')    window.API.put    = (path, body) => apiSend('PUT', path, body);
  if (typeof window.API.patch !== 'function')  window.API.patch  = (path, body) => apiSend('PATCH', path, body);
  if (typeof window.API.delete !== 'function') window.API.delete = (path) => apiDelete(path);

  // Compat: API.request / API.toast
  if (typeof window.API.request !== 'function') {
    window.API.request = async function(path, { method='GET', headers={}, json, body, userId = window.API.userId } = {}) {
      const base = window.API.baseUrl || '';
      const h = buildHeaders(headers);
      const upper = String(method).toUpperCase();
      if (json !== undefined) h['Content-Type'] = 'application/json';

      const res = await fetch(base + path, {
        method: upper,
        headers: h,
        body: json !== undefined ? JSON.stringify(json) : (body ?? null)
      });
      return handleResponse(res);
    };
  }
  if (typeof window.API.toast !== 'function') {
    window.API.toast = (msg, type='info') => showToast(msg, type);
  }
})();

/* =========================================================
 * Exposición utilitaria (por si alguien la necesita)
 * ========================================================= */
window.NT = window.NT || {};
window.NT.http = {
  request: async (pathOrUrl, options = {}) => {
    const res = await fetch(pathOrUrl, options);
    const text = await res.text();
    const tryJson = () => { try { return text ? JSON.parse(text) : null; } catch { return null; } };
    if (res.ok) return (tryJson() ?? text ?? null);
    let msg = text || `HTTP ${res.status}`;
    const j = tryJson(); msg = j ? (j.detail || j.message || j.error || JSON.stringify(j)) : ntParseApiError(msg);
    throw new Error(msg);
  },
  getJson:  (url, params) => (params ? fetch(new URL(__absUrl(url))).then(handleResponse) : fetch(url).then(handleResponse)),
  postJson: (url, body)   => fetch(url, { method:'POST', body }).then(handleResponse),
  putJson:  (url, body)   => fetch(url, { method:'PUT',  body }).then(handleResponse),
  patchJson:(url, body)   => fetch(url, { method:'PATCH',body }).then(handleResponse),
  del:      (url)         => fetch(url, { method:'DELETE'}).then(handleResponse),
  withQuery: function(url, params = {}) {
    const u = new URL(__absUrl(url));
    Object.entries(params).forEach(([k,v]) => { if (v!==undefined && v!==null && v!=='') u.searchParams.append(k,v); });
    return u.toString();
  }
};

/* =========================================================
 * Compat helpers para Dashboard (NO rompe nada existente)
 * Añadidos al final de common.js
 * ========================================================= */
(function compatForDashboard(){
  // Devuelve la base de la API respetando: API.baseUrl -> API_BASE -> <meta api-base> -> LS
  if (typeof window.getApiBase !== 'function') {
    window.getApiBase = function () {
      try {
        if (window.API && window.API.baseUrl) return String(window.API.baseUrl).trim();
        if (window.API_BASE) return String(window.API_BASE).trim();
        const meta = document.querySelector('meta[name="api-base"]');
        if (meta && meta.getAttribute('content')) return meta.getAttribute('content').trim();
        const fromLS = localStorage.getItem('api_base');
        return (fromLS || '').trim();
      } catch { return ''; }
    };
  }

  // GET sencillo que usa buildHeaders + handleResponse y acepta params opcionales
  if (typeof window.ntGet !== 'function') {
    window.ntGet = async function (pathOrUrl, params = null) {
      // Construir URL absoluta
      let urlStr = pathOrUrl;
      const isAbs = /^https?:\/\//i.test(String(pathOrUrl));
      if (!isAbs) {
        const base = (window.getApiBase && window.getApiBase()) || '';
        if (base) {
          const baseTrim = base.replace(/\/+$/,'');
          const pathTrim = String(pathOrUrl).replace(/^\/+/,'');
          urlStr = baseTrim + '/' + pathTrim;
        } else {
          urlStr = __absUrl(String(pathOrUrl));
        }
      }

      // Adjuntar query params si vienen
      if (params && typeof params === 'object') {
        const u = new URL(urlStr, window.location.origin);
        Object.entries(params).forEach(([k,v])=>{
          if (v !== undefined && v !== null && v !== '') u.searchParams.append(k, v);
        });
        urlStr = u.toString();
      }

      // Usa el mismo fallback del parche global
      const res = await __fetchWithFallback(fetch, urlStr, { headers: buildHeaders() });
      return handleResponse(res);
    };
  }

  // (Opcional) atajo POST por si algún módulo lo espera
  if (typeof window.ntPost !== 'function') {
    window.ntPost = async function (pathOrUrl, body) {
      const base = (window.getApiBase && window.getApiBase()) || '';
      const url = /^https?:\/\//i.test(pathOrUrl)
        ? pathOrUrl
        : (base ? base.replace(/\/+$/,'') + '/' + String(pathOrUrl).replace(/^\/+/,'') : __absUrl(pathOrUrl));
      const res = await __fetchWithFallback(fetch, url, {
        method:'POST',
        headers: buildHeaders({'Content-Type':'application/json'}),
        body: JSON.stringify(body ?? {})
      });
      return handleResponse(res);
    };
  }
})();
