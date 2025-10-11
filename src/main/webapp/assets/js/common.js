/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

/* 
 * Utilidades comunes a todas las páginas
 * (Mantiene compatibilidad con Proveedores y añade helpers para Compras)
 */
/* common.js — utilidades globales */
(function(){
  console.debug('[common] loaded');

  // Lee la base de API desde meta o variable global. Fallback: mismo origen del frontend.
  window.getApiBase = function() {
    try {
      if (window.API_BASE) return String(window.API_BASE).replace(/\/$/, '');
      const meta = document.querySelector('meta[name="api-base"]');
      if (meta && meta.content) return String(meta.content).replace(/\/$/, '');
    } catch {}
    return location.origin.replace(/\/$/, '');
  };

  // ===== Toasts (mantiene API previa) =====
  window.ntToast = function ({title='Mensaje', body='', type='info', delay=4500}) {
    const container = document.getElementById('toastStack');
    if (!container) { console.warn('[ntToast] Falta #toastStack'); return; }
    const toast = document.createElement('div');
    toast.className = `toast nt-toast-${type}`;
    toast.innerHTML = `
      <div class="toast-header">
        <i class="bi ${type==='success'?'bi-check-circle-fill':type==='error'?'bi-x-circle-fill':'bi-info-circle-fill'} me-2"></i>
        <strong class="me-auto">${title}</strong>
        <button class="btn-close" data-bs-dismiss="toast" aria-label="Cerrar"></button>
      </div>
      <div class="toast-body">${body}</div>`;
    container.appendChild(toast);
    const bs = new bootstrap.Toast(toast, {delay});
    bs.show();
    toast.addEventListener('hidden.bs.toast', ()=> toast.remove());
  };
  window.showToast = (message, type='info', title='Mensaje') => window.ntToast({ title, body: message, type, delay: 4200 });

  // Helpers
  window.ntEsc = s => String(s ?? '').replace(/[&<>"']/g, m=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));
  window.ntParseApiError = (txt) => { try { const j=JSON.parse(txt); return j.error||j.message||j.detail||txt; } catch { return txt; } };

  // Confirm modal
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

  // Fetch JSON con manejo de errores
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
})();
