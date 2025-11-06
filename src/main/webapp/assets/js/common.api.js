/* 
 * Helpers comunes para llamadas REST y UX consistente.
 * - Inyecta Authorization: Bearer <token> si existe sesión (Auth.save / nt.session / auth_token / sessionToken).
 * - (Compat) Inyecta X-User-Id para SPs que lo requieran.
 * - Maneja JSON y errores.
 * - Toast simple para feedback.
 */

const API = {
  // Si guardaste un api_base en localStorage, úsalo; si no, relativo al mismo host
    baseUrl: (localStorage.getItem('api_base') 
    || (document.querySelector('meta[name="api-base"]')?.getAttribute('content')?.trim() || '')),


  // (Compat) Si algún SP aún lee esta cabecera:
  userId: 1,

  // Atajos convenientes
  get: (path, params = {}) => apiGet(path, params),
  post: (path, body) => apiSend('POST', path, body),
  put: (path, body) => apiSend('PUT', path, body),
  patch: (path, body) => apiSend('PATCH', path, body),
  delete: (path) => apiDelete(path)
};

/* =========================
 *   Sesión / Headers
 * ========================= */

// Lee la sesión desde varias fuentes (compat)
function loadSession() {
  // 1) nt.session (usado por Auth.save en varias implementaciones)
  try {
    const raw = localStorage.getItem('nt.session');
    if (raw) {
      const s = JSON.parse(raw);
      if (s && s.token) return s;
    }
  } catch {}

  // 2) Auth.load() si está disponible
  try {
    if (window.Auth && typeof Auth.load === 'function') {
      const s = Auth.load();
      if (s && s.token) return s;
    }
  } catch {}

  // 3) auth_token o sessionToken sueltos
  const t = localStorage.getItem('auth_token') || localStorage.getItem('sessionToken');
  if (t) return { token: t };

  return null;
}

// Construye headers comunes (Authorization + compat)
function buildHeaders(extra = {}) {
  const h = {
    'Accept': 'application/json',
    ...extra
  };

  // Bearer si hay token
  const s = loadSession();
  if (s?.token) h['Authorization'] = 'Bearer ' + s.token;

  // Compatibilidad con back/BD legacy
  if (API.userId != null) h['X-User-Id'] = String(API.userId);

  return h;
}

/* =========================
 *   HTTP Helpers
 * ========================= */

// GET con query params
async function apiGet(path, params = {}) {
  const url = new URL(API.baseUrl + path, window.location.origin);
  Object.entries(params).forEach(([k, v]) => {
    if (v !== undefined && v !== null && v !== '') url.searchParams.append(k, v);
  });
  const res = await fetch(url, { headers: buildHeaders() });
  return handleResponse(res);
}

// POST/PUT/PATCH JSON
async function apiSend(method, path, bodyObj) {
  const res = await fetch(API.baseUrl + path, {
    method,
    headers: buildHeaders({ 'Content-Type': 'application/json' }),
    body: (bodyObj === undefined ? null : JSON.stringify(bodyObj))
  });
  return handleResponse(res);
}

// DELETE
async function apiDelete(path) {
  const res = await fetch(API.baseUrl + path, {
    method: 'DELETE',
    headers: buildHeaders()
  });
  return handleResponse(res);
}

/* =========================
 *   Respuesta / Errores
 * ========================= */

async function handleResponse(res) {
  // Intenta parsear como texto primero (para manejar JSON y texto plano)
  const text = await res.text();
  const tryJson = () => { try { return text ? JSON.parse(text) : null; } catch { return null; } };

  if (res.ok) {
    const data = tryJson();
    return (data !== null ? data : text || null);
  }

  // Manejo de 401/403: si estamos logueados, puede ser token inválido/expirado
  if (res.status === 401 || res.status === 403) {
    // Limpia sesión y redirige al login, pero solo si hay sesión
    const s = loadSession();
    if (s?.token) {
      // Evita loop infinito si ya estás en login
      const isLogin = /login\.jsp$/i.test(location.pathname) || /index\.jsp$/i.test(location.pathname);
      if (!isLogin) {
        try { localStorage.removeItem('nt.session'); } catch {}
        try { localStorage.removeItem('auth_token'); localStorage.removeItem('sessionToken'); } catch {}
        showToast('Sesión expirada. Vuelve a iniciar sesión.', 'warning');
        setTimeout(() => { window.location.href = 'index.jsp'; }, 600);
      }
    }
  }

  // Construye mensaje de error amigable
  let msg = text || `HTTP ${res.status}`;
  const j = tryJson();
  if (j) {
    msg = j.detail || j.message || j.error || JSON.stringify(j);
  }
  throw new Error(msg);
}

/* =========================
 *   UI Utils
 * ========================= */

// Toast Bootstrap
function showToast(message, level = 'primary') {
  const toastEl = document.getElementById('appToast');
  const msgEl = document.getElementById('toastMsg');
  if (!toastEl || !msgEl) {
    // Fallback mínimo
    console[level === 'danger' ? 'error' : 'log'](`[${level}] ${message}`);
    return;
  }
  msgEl.textContent = message;
  toastEl.className = `toast align-items-center text-bg-${level} border-0`;
  bootstrap.Toast.getOrCreateInstance(toastEl, { delay: 2800 }).show();
}

// Util: form -> obj
function formToObject(formEl) {
  const data = {};
  new FormData(formEl).forEach((v, k) => { data[k] = v; });
  return data;
}

// Util: set values by id
function setValue(id, value) {
  const el = document.getElementById(id);
  if (el) el.value = value ?? '';
}

/* =========================
 *   Parche global de fetch (compat páginas antiguas)
 * =========================
 * Si alguna página hace fetch(...) directo sin usar API.*, le inyectamos el
 * Authorization automáticamente siempre que no lo haya puesto explícitamente.
 */
(function patchFetchForAuth(){
  if (!window.fetch) return;
  const originalFetch = window.fetch;
  window.fetch = function(input, init) {
    init = init || {};
    // Normaliza headers
    let hdrs = init.headers instanceof Headers ? init.headers : new Headers(init.headers || {});
    // Si NO viene Authorization, lo agregamos
    if (!hdrs.has('Authorization')) {
      const s = loadSession();
      if (s && s.token) hdrs.set('Authorization', 'Bearer ' + s.token);
    }
    // Compat X-User-Id si no está
    if (!hdrs.has('X-User-Id') && API.userId != null) {
      hdrs.set('X-User-Id', String(API.userId));
    }
    // Asegura Accept por defecto
    if (!hdrs.has('Accept')) hdrs.set('Accept', 'application/json');
    init.headers = hdrs;
    return originalFetch(input, init);
  };
})();
