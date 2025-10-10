/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

(() => {
  // Ajusta esta URL si cambia tu backend
  const API_PROV = 'http://localhost:8080/api/proveedores';

  const kpiProv = document.getElementById('kpiProvActivos');
  const kpiComprasMes = document.getElementById('kpiComprasMes');
  const kpiCxP = document.getElementById('kpiCxPPendiente');
  const kpiPagosMes = document.getElementById('kpiPagosMes');
  const tbody = document.getElementById('tblUltimosProv');
  const btnRefrescar = document.getElementById('btnRefrescar');

  async function loadKPIs() {
    try {
      // KPI proveedores activos usando paginado para obtener total
      const res = await fetch(`${API_PROV}?activo=true&page=0&size=1`);
      if (!res.ok) throw new Error(await res.text());
      const json = await res.json();
      kpiProv.textContent = json.totalElements ?? '--';

      // Placeholders hasta tener endpoints específicos
      kpiComprasMes.textContent = 'Q 0.00';
      kpiCxP.textContent       = 'Q 0.00';
      kpiPagosMes.textContent  = 'Q 0.00';
    } catch (e) {
      ntToast({title:'Aviso', body:'No fue posible cargar los KPIs.', type:'info'});
      console.error(e);
    }
  }

  async function loadUltimosProveedores() {
    try {
      const res = await fetch(`${API_PROV}?page=0&size=5`);
      if (!res.ok) throw new Error(await res.text());
      const json = await res.json();
      const rows = (json.content || []).map(p => `
        <tr>
          <td>${ntEsc(p.codigo)}</td>
          <td>${ntEsc(p.nombre)}</td>
          <td>${ntEsc(p.nit)}</td>
          <td>${ntEsc(p.telefono)}</td>
          <td class="text-center">${p.dias_credito ?? ''}</td>
        </tr>
      `).join('');
      tbody.innerHTML = rows || `<tr><td colspan="5" class="text-center text-muted">Sin datos</td></tr>`;
    } catch (e) {
      tbody.innerHTML = `<tr><td colspan="5" class="text-center text-muted">No disponible</td></tr>`;
    }
  }

  function renderChart() {
    const ctx = document.getElementById('chartCompras');
    const labels = ['S1','S2','S3','S4','S5','S6'];
    const data = [3, 5, 2, 6, 4, 7]; // Placeholder
    new Chart(ctx, {
      type: 'bar',
      data: { labels, datasets: [{ label:'Órdenes', data }] },
      options: { responsive:true, maintainAspectRatio:false }
    });
  }

  async function init(){
    await Promise.all([loadKPIs(), loadUltimosProveedores()]);
    renderChart();
  }

  btnRefrescar.addEventListener('click', init);
  init();
})();
