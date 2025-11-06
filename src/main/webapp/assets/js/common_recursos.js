/* 
 * assets/js/rrhh/common.js
 * Helpers compartidos: HTTP, sesión, toasts, dashboard y catálogos
 * (versión robusta, no elimina nada de lo original; solo añade compat y resiliencia)
 */

(function (global) {
  /* =========================
   *   BASE DEL BACKEND
   * ========================= */
  (function resolveBase() {
    try {
      const meta = document.querySelector('meta[name="api-base"]');
      const fromMeta = meta?.getAttribute('content')?.trim() || '';
      const fromLS   = localStorage.getItem('api_base') || '';
      global.BACKEND_BASE = (global.BACKEND_BASE || fromLS || fromMeta || 'http://localhost:8080').replace(/\/$/, '');
    } catch {
      global.BACKEND_BASE = 'http://localhost:8080';
    }
  })();

  // Base local para exportar en NT
  const baseUrl = global.BACKEND_BASE;

  /* =========================
   *   SESIÓN / AUTH
   * ========================= */
  function loadSessionCompat() {
    // 1) nt.session (formato {token, expiresAt, user})
    try {
      const raw = localStorage.getItem('nt.session');
      if (raw) {
        const s = JSON.parse(raw);
        if (s?.token) return s;
      }
    } catch {}

    // 2) Auth.load() si lo tienes
    try {
      if (global.Auth && typeof global.Auth.load === 'function') {
        const s = global.Auth.load();
        if (s?.token) return s;
      }
    } catch {}

    // 3) Tokens sueltos
    const t = localStorage.getItem('sessionToken') || localStorage.getItem('auth_token');
    if (t) return { token: t };

    // 4) Inyección del servidor
    if (global.sessionTokenFromServer) return { token: global.sessionTokenFromServer };

    return null;
  }

  function getToken() {
    return loadSessionCompat()?.token || '';
  }

  function authHeader() {
    const t = getToken();
    return t ? { 'Authorization': 'Bearer ' + t } : {};
  }

  /* =========================
   *   UTILES DE URL/ERRORES
   * ========================= */
  function absUrl(pathOrUrl) {
    if (!pathOrUrl) return baseUrl;
    if (/^https?:\/\//i.test(pathOrUrl)) return pathOrUrl;
    if (pathOrUrl.startsWith('/')) return baseUrl + pathOrUrl;
    // relativo al documento → conviértelo a absoluto del host actual
    return new URL(pathOrUrl, window.location.origin).toString();
  }

  function extractMessageFromHtml(html) {
    try {
      const tmp = document.implementation.createHTMLDocument('');
      tmp.documentElement.innerHTML = html;
      const t = tmp.querySelector('title')?.textContent?.trim();
      const h1 = tmp.querySelector('h1')?.textContent?.trim();
      const joined = [t, h1].filter(Boolean).join(' – ');
      return joined || html.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim().slice(0, 200);
    } catch { return String(html); }
  }

  function parseApiError(text, status) {
    if (!text) return `HTTP ${status}`;
    // JSON
    try {
      const j = JSON.parse(text);
      return j.detail || j.message || j.error || `HTTP ${status}`;
    } catch {}
    // HTML (Tomcat)
    if (/<html[^>]*>/i.test(text)) return extractMessageFromHtml(text);
    // Texto plano
    return text;
  }

  /* =========================
   *   HTTP (inyecta Bearer)
   * ========================= */
  async function http(urlOrPath, opts = {}) {
    const url = absUrl(String(urlOrPath || ''));
    const method = String(opts.method || 'GET').toUpperCase();

    // Headers base
    const headers = new Headers(opts.headers || {});
    if (!headers.has('Accept')) headers.set('Accept', 'application/json');
    // Compat X-User-Id (si algún SP lo necesita)
    if (!headers.has('X-User-Id')) headers.set('X-User-Id', '1');

    // Authorization
    if (!headers.has('Authorization')) {
      const t = getToken();
      if (t) headers.set('Authorization', 'Bearer ' + t);
    }

    // Content-Type JSON solo si mandamos body
    const hasBody = opts.body !== undefined && opts.body !== null;
    if (hasBody && !headers.has('Content-Type')) headers.set('Content-Type', 'application/json');

    // Normaliza body si es objeto y Content-Type es JSON
    let body = opts.body;
    if (hasBody && headers.get('Content-Type')?.includes('application/json') && typeof body !== 'string') {
      try { body = JSON.stringify(body); } catch {}
    }

    const res = await fetch(url, { ...opts, method, headers, body });
    const raw = await res.text();

    if (res.ok) {
      if (!raw) return null;
      try { return JSON.parse(raw); } catch { return raw; }
    }

    // 401/403 → limpiar y redirigir (si no estamos en login/index)
    if (res.status === 401 || res.status === 403) {
      try { localStorage.removeItem('nt.session'); } catch {}
      try { localStorage.removeItem('auth_token'); localStorage.removeItem('sessionToken'); } catch {}
      const p = (location.pathname || '').toLowerCase();
      const inLogin = p.endsWith('/login.jsp') || p.endsWith('/index.jsp');
      if (!inLogin) setTimeout(() => location.href = 'index.jsp', 500);
    }

    const nice = parseApiError(raw, res.status);
    throw new Error(nice);
  }

  /* =========================
   *   TOASTS (Bootstrap)
   * ========================= */
  let toastRef;
  function ensureToast() {
    if (toastRef) return toastRef;
    const el = document.getElementById('ntToast');
    if (!el || typeof bootstrap === 'undefined') return null;
    toastRef = new bootstrap.Toast(el, { delay: 3500 });
    return toastRef;
  }
  function showToast(title, body, type = 'info') {
    const t = ensureToast();
    if (!t) {
      // Fallback si no hay Bootstrap Toast
      alert((title ? title + ': ' : '') + (body || ''));
      return;
    }
    const wrap = document.getElementById('ntToast');
    wrap.classList.remove('nt-toast-success', 'nt-toast-error', 'nt-toast-info');
    wrap.classList.add(type === 'success' ? 'nt-toast-success' : (type === 'error' ? 'nt-toast-error' : 'nt-toast-info'));
    const ttl = document.getElementById('toastTitle');
    const msg = document.getElementById('toastBody');
    const tim = document.getElementById('toastTime');
    if (ttl) ttl.innerText = title || 'Info';
    if (msg) msg.innerText = body || '';
    if (tim) tim.innerText = new Date().toLocaleTimeString();
    t.show();
  }

  /* =========================
   *   NAVBAR / ME / LOGOUT
   * ========================= */
  async function loadMe() {
    try {
      const me = await http('/api/auth/me');
      const slot = document.getElementById('loginUser');
      if (slot) slot.innerText = (me?.nombreUsuario || 'Usuario') + (me?.rolNombre ? ' · ' + me.rolNombre : '');
    } catch {
      const slot = document.getElementById('loginUser');
      if (slot) slot.innerText = 'Sesión no iniciada';
    }
  }

  async function logout() {
    const t = getToken();
    if (t) {
      try {
        await http('/api/auth/logout', { method: 'POST', body: { token: t } });
      } catch { /* no romper flujo de salida */ }
    }
    try { localStorage.removeItem('nt.session'); } catch {}
    try { localStorage.removeItem('auth_token'); localStorage.removeItem('sessionToken'); } catch {}
    global.sessionTokenFromServer = '';
    showToast('Sesión', 'Has cerrado sesión', 'success');
    setTimeout(() => location.href = 'index.jsp', 700);
  }

  /* =========================
   *   DASHBOARD KPIs RRHH
   * ========================= */
  async function loadDashboardKPIs() {
    const d = await http('/api/rrhh/dashboard');
    const set = (id, val) => { const el = document.getElementById(id); if (el) el.innerText = (val ?? '—'); };
    set('kpiEmpTotal', d.totalEmpleados);
    set('kpiEmpActivos', d.activos);
    set('kpiEmpInactivos', d.inactivos);
    set('kpiEmpSuspendidos', d.suspendidos);
    set('kpiDeptoTotal', d.totalDepartamentos);
    set('kpiPuestosTotal', d.totalPuestos);
  }

  /* =========================
   *   CATÁLOGOS RRHH
   * ========================= */
  async function loadDepartamentosCatalog() {
    return http('/api/rrhh/departamentos');
  }
  async function loadPuestosCatalog(departamentoId = null) {
    const u = new URL(absUrl('/api/rrhh/puestos'));
    if (departamentoId) u.searchParams.set('departamentoId', departamentoId);
    return http(u.toString());
  }
  async function loadEmpleadosPageForJefes(size = 100) {
    const u = new URL(absUrl('/api/rrhh/empleados'));
    u.searchParams.set('page', 0);
    u.searchParams.set('size', size);
    return http(u.toString());
  }

  /* =========================
   *   PAGINACIÓN SIMPLE
   * ========================= */
  function renderPagination(el, pageNumber, totalPages, onChange) {
    if (!el) return;
    el.innerHTML = '';
    const make = (label, target, disabled = false, active = false) => {
      const li = document.createElement('li');
      li.className = `page-item ${disabled ? 'disabled' : ''} ${active ? 'active' : ''}`;
      const a = document.createElement('a');
      a.className = 'page-link'; a.href = '#'; a.innerText = label;
      a.addEventListener('click', (ev) => { ev.preventDefault(); if (!disabled) onChange(target); });
      li.appendChild(a); return li;
    };
    el.appendChild(make('«', 0, pageNumber === 0));
    el.appendChild(make('‹', Math.max(pageNumber - 1, 0), pageNumber === 0));
    for (let i = 0; i < totalPages; i++) el.appendChild(make(String(i + 1), i, false, i === pageNumber));
    el.appendChild(make('›', Math.min(pageNumber + 1, totalPages - 1), pageNumber >= totalPages - 1));
    el.appendChild(make('»', totalPages - 1, pageNumber >= totalPages - 1));
  }

  /* =========================
   *   EXPORTAR EN GLOBAL
   * ========================= */
  global.NT = {
    baseUrl,
    http,
    showToast,
    loadMe,
    logout,
    loadDashboardKPIs,
    loadDepartamentosCatalog,
    loadPuestosCatalog,
    loadEmpleadosPageForJefes,
    renderPagination
  };
})(window);
