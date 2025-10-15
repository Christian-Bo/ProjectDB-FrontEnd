/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


// assets/js/rrhh/common.js
// Helpers compartidos: HTTP, sesión, toasts, dashboard y catálogos

(function (global) {
  const baseUrl = global.BACKEND_BASE || 'http://localhost:8080'; 

  // ======= Sesión / Auth =======
  function getToken() {
    return (window.sessionTokenFromServer || '') ||
           localStorage.getItem('sessionToken')   ||
           localStorage.getItem('auth_token')     || '';   // 👈 añade este fallback
  }
  function authHeader() {
    const t = getToken();
    return t ? { 'Authorization': 'Bearer ' + t } : {};
  }

  // ======= HTTP =======
  async function http(url, opts = {}) {
    const res = await fetch(url, {
      ...opts,
      headers: { 'Content-Type': 'application/json', ...authHeader(), ...(opts.headers || {}) }
    });
    if (!res.ok) {
      let msg = 'Error ' + res.status;
      try { const j = await res.json(); msg = j.detail || j.error || msg; } catch (_) { }
      throw new Error(msg);
    }
    return res.status === 204 ? null : res.json();
  }

  // ======= Toasts (Bootstrap) =======
  let toastRef;
  function ensureToast() {
    if (toastRef) return toastRef;
    const el = document.getElementById('ntToast');
    if (!el) return null;
    toastRef = new bootstrap.Toast(el, { delay: 3500 });
    return toastRef;
  }
  function showToast(title, body, type = 'info') {
    const t = ensureToast();
    if (!t) return alert((title ? title + ': ' : '') + (body || ''));
    const wrap = document.getElementById('ntToast');
    wrap.classList.remove('nt-toast-success', 'nt-toast-error', 'nt-toast-info');
    wrap.classList.add(type === 'success' ? 'nt-toast-success' : (type === 'error' ? 'nt-toast-error' : 'nt-toast-info'));
    document.getElementById('toastTitle').innerText = title || 'Info';
    document.getElementById('toastBody').innerText = body || '';
    document.getElementById('toastTime').innerText = new Date().toLocaleTimeString();
    t.show();
  }

  // ======= Navbar / Me =======
  async function loadMe() {
    try {
      const me = await http(`${baseUrl}/api/auth/me`);
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
      try { await http(`${baseUrl}/api/auth/logout`, { method: 'POST', body: JSON.stringify({ token: t }) }); } catch { }
    }
    localStorage.removeItem('sessionToken');
    global.sessionTokenFromServer = '';
    showToast('Sesión', 'Has cerrado sesión', 'success');
    setTimeout(() => location.reload(), 700);
  }

  // ======= Dashboard KPIs =======
  async function loadDashboardKPIs() {
    const d = await http(`${baseUrl}/api/rrhh/dashboard`);
    const set = (id, val) => { const el = document.getElementById(id); if (el) el.innerText = (val ?? '—'); };
    set('kpiEmpTotal', d.totalEmpleados);
    set('kpiEmpActivos', d.activos);
    set('kpiEmpInactivos', d.inactivos);
    set('kpiEmpSuspendidos', d.suspendidos);
    set('kpiDeptoTotal', d.totalDepartamentos);
    set('kpiPuestosTotal', d.totalPuestos);
  }

  // ======= Catálogos =======
  async function loadDepartamentosCatalog() {
    return http(`${baseUrl}/api/rrhh/departamentos`);
  }
  async function loadPuestosCatalog(departamentoId = null) {
    const url = new URL(`${baseUrl}/api/rrhh/puestos`, location.origin);
    if (departamentoId) url.searchParams.set('departamentoId', departamentoId);
    return http(url.toString());
  }
  async function loadEmpleadosPageForJefes(size = 100) {
    const url = new URL(`${baseUrl}/api/rrhh/empleados`, location.origin);
    url.searchParams.set('page', 0); url.searchParams.set('size', size);
    return http(url.toString());
  }

  // ======= Util: paginación simple =======
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

  // Exponer en global
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
