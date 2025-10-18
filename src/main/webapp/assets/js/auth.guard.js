/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

/* Simple role-based guard + dashboard redirect.
   Requires: after login, you store token and user in localStorage under 'nt.session'
   nt.session = { token, expiresAt, user: { id, nombreUsuario, rolId, rolNombre, estado } }
*/
const Auth = (()=>{
  const key = 'nt.session';
  function load(){ try{ return JSON.parse(localStorage.getItem(key) || 'null'); }catch{ return null; } }
  function save(data){ localStorage.setItem(key, JSON.stringify(data)); }
  function clear(){ localStorage.removeItem(key); }
  function token(){ const s = load(); return s?.token || null; }
  function role(){ const s = load(); return (s?.user?.rolNombre || '').toUpperCase(); }
  function ensure(allowed){
    const t = token();
    if(!t){ window.location.href = 'login.jsp'; return false; }
    const r = role();
    if (r === 'ADMIN') return true;
    if (!allowed.map(x=>x.toUpperCase()).includes(r)){
      // auditor: allow read-only pages if they mark data-readonly attr
      const readOnly = document.body?.getAttribute('data-readonly') === '1';
      if (r === 'AUDITOR' && readOnly) return true;
      // otherwise bounce to dashboard
      gotoDashboard();
      return false;
    }
    return true;
  }
  function gotoDashboard(){
    const r = role();
    const map = {
      'ADMIN': 'dashboard_admin.jsp',
      'OPERACIONES': 'dashboard_operaciones.jsp',
      'FINANZAS': 'dashboard_finanzas.jsp',
      'RRHH': 'dashboard_rrhh.jsp',
      'AUDITOR': 'dashboard_auditor.jsp'
    };
    window.location.href = map[r] || 'login.jsp';
  }
  return { load, save, clear, token, role, ensure, gotoDashboard };
})();

