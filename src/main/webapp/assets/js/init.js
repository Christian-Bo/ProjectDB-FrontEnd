/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


(function (global) {
  const { loadMe, loadDashboardKPIs } = global.NT;

  async function init() {
    // Navbar
    const btnLogout = document.getElementById('btnLogout');
    if (btnLogout) btnLogout.addEventListener('click', global.NT.logout);
    await loadMe();

    // KPIs
    await loadDashboardKPIs();

    // Módulos
    if (global.RRHH_Empleados?.initEmpleados) await global.RRHH_Empleados.initEmpleados();
    if (global.RRHH_Puestos?.initPuestos) await global.RRHH_Puestos.initPuestos();
    if (global.RRHH_Departamentos?.initDepartamentos) await global.RRHH_Departamentos.initDepartamentos();
  }

  // DOM listo
  window.addEventListener('DOMContentLoaded', init);
})(window);

