/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

/* 
 * Utilidades comunes a todas las páginas
 * (Mantiene compatibilidad con Proveedores y añade helpers para Compras)
 */

(function(){
  console.debug('[common] loaded v11');

  // ===== Base de API =====
  window.getApiBase = function() {
    try {
      if (window.API_BASE) return String(window.API_BASE).replace(/\/$/, '');
      const meta = document.querySelector('meta[name="api-base"]');
      if (meta && meta.content) return String(meta.content).replace(/\/$/, '');
    } catch {}
    return location.origin.replace(/\/$/, '');
  };

  // ===== Toasts =====
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

  // ===== Helpers =====
  window.ntEsc = s => String(s ?? '').replace(/[&<>"']/g, m=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));
  window.ntParseApiError = (txt) => { try { const j=JSON.parse(txt); return j.error||j.message||j.detail||txt; } catch { return txt; } };

  window.confirmDialog = function(message, {title='Confirmar', okText='Aceptar', cancelText='Cancelar'} = {}) {
    return new Promise((resolve) => {
      const id = 'ntConfirmModal';
      let m = document.getElementById(id);
      if (!m) {
        const html = `
        <div class="modal fade" id="${id}" tabindex="-1" aria-hidden="true">
          <div class="modal-dialog"><div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title"><i class="bi bi-question-circle me-2"></i><span id="${id}-title"></span></h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body"><div id="${id}-msg" class="fw-medium"></div></div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" data-bs-dismiss="modal" id="${id}-cancel">${cancelText}</button>
              <button type="button" class="btn btn-primary" id="${id}-ok">${okText}</button>
            </div>
          </div></div>
        </div>`;
        document.body.insertAdjacentHTML('beforeend', html);
        m = document.getElementById(id);
      }
      document.getElementById(`${id}-title`).textContent = title;
      document.getElementById(`${id}-msg`).textContent = message;
      document.getElementById(`${id}-ok`).textContent = okText;
      document.getElementById(`${id}-cancel`).textContent = cancelText;

      const modal = new bootstrap.Modal(m);
      const btnOk = document.getElementById(`${id}-ok`);
      const onOk = () => { btnOk.removeEventListener('click', onOk); modal.hide(); resolve(true); };
      btnOk.addEventListener('click', onOk);
      m.addEventListener('hidden.bs.modal', () => resolve(false), { once: true });
      modal.show();
    });
  };

  // ===== Fetch JSON helpers =====
  async function ntFetchJson(method, url, body) {
    const opts = { method, headers: {} };
    if (body !== undefined) { opts.headers['Content-Type'] = 'application/json'; opts.body = JSON.stringify(body); }
    const res = await fetch(url, opts);
    const raw = await res.text();
    if (!res.ok) { throw new Error(window.ntParseApiError(raw)); }
    return raw ? JSON.parse(raw) : null;
  }
  window.ntGet    = (url)        => ntFetchJson('GET', url);
  window.ntPost   = (url, body)  => ntFetchJson('POST', url, body);
  window.ntPut    = (url, body)  => ntFetchJson('PUT', url, body);
  window.ntDelete = (url)        => ntFetchJson('DELETE', url);

  // ===== Compat API.request / API.toast =====
  window.API = (function () {
    const RAW_BASE = getApiBase();
    const BASE = RAW_BASE.replace(/\s+$/g, '').replace(/\/+$/, '');

    function buildUrl(path) {
      if (/^https?:\/\//i.test(path)) return path;
      const slash = path.startsWith('/') ? '' : '/';
      let url = `${BASE}${slash}${path}`;
      return url.replace(/([^:]\/)\/+/g, '$1');
    }

    async function request(path, { method = 'GET', headers = {}, json, body, userId = 1 } = {}) {
      const upper = String(method).toUpperCase();
      const baseHeaders = {
        'Accept': 'application/json'
      };
      // SOLO agregamos X-User-Id cuando el backend lo pide (create/update/delete)
      if (upper === 'POST' || upper === 'PUT' || upper === 'DELETE') {
        baseHeaders['X-User-Id'] = String(userId);
      }
      if (json !== undefined) {
        baseHeaders['Content-Type'] = 'application/json'; // esto sí provoca preflight en POST/PUT (esperado)
      }

      const h = { ...baseHeaders, ...headers };

      const res = await fetch(buildUrl(path), {
        method: upper,
        mode: 'cors',                                     // explícito
        headers: h,
        body: json !== undefined ? JSON.stringify(json) : body,
      });

      const ct = res.headers.get('content-type') || '';
      const payload = await (ct.includes('application/json') ? res.json() : res.text());

      if (!res.ok) {
        const msg = typeof payload === 'string' ? payload : (payload?.message || payload?.error || res.statusText);
        throw new Error(`HTTP ${res.status} – ${msg}`);
      }
      return payload;
    }

    function toast(msg, type = 'info') {
      showToast(msg, type);
    }

    return { request, toast };
  })();

})();
