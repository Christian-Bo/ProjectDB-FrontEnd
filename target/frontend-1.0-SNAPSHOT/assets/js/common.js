/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

// Utilidades comunes a todas las páginas
(function(){
  // Toasts Bootstrap con estilos propios
  window.ntToast = function ({title='Mensaje', body='', type='info', delay=4500}) {
    const container = document.getElementById('toastStack');
    const toast = document.createElement('div');
    toast.className = `toast nt-toast-${type}`;
    toast.innerHTML = `
      <div class="toast-header">
        <i class="bi ${type==='success'?'bi-check-circle-fill':type==='error'?'bi-x-circle-fill':'bi-info-circle-fill'} me-2"></i>
        <strong class="me-auto">${title}</strong>
        <button class="btn-close" data-bs-dismiss="toast"></button>
      </div>
      <div class="toast-body">${body}</div>
    `;
    container.appendChild(toast);
    const bs = new bootstrap.Toast(toast, {delay});
    bs.show();
    toast.addEventListener('hidden.bs.toast', ()=> toast.remove());
  };

  // Escape HTML para evitar XSS en plantillas
  window.ntEsc = s => String(s ?? '').replace(/[&<>"']/g, m=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));

  // Parsea error de API (intenta JSON)
  window.ntParseApiError = (txt) => {
    try { const j = JSON.parse(txt); return j.message || j.detail || txt; }
    catch { return txt; }
  };
})();
