/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

// Dashboard — KPIs, últimas entidades y gráfico

// ===== Utilidades y base =====
const API_BASE = (document.querySelector('meta[name="api-base"]')?.content || location.origin).replace(/\/$/, '');
const API_PROV = `${API_BASE}/api/proveedores`;   // se asume que tu módulo de proveedores ya existe
const API_COMP = `${API_BASE}/api/compras`;

// helper DOM
const $ = (s,c=document)=>c.querySelector(s);
const $$ = (s,c=document)=>Array.from(c.querySelectorAll(s));
const fmtMoney = v => (v==null?'0.00':Number(v).toLocaleString('es-GT',{minimumFractionDigits:2, maximumFractionDigits:2}));

// ====== Proveedores: KPI y últimos 3 ======
async function kpiProveedoresActivos() {
  // Estrategia:
  // 1) Intento obtener paginado y leer totalElements (muchos backends lo exponen).
  // 2) Si no, traigo una página grande y cuento.
  try {
    // patrón 1: paginado con totalElements
    const q1 = `${API_PROV}?activo=true&page=0&size=1`;
    const r1 = await ntGet(q1);
    if (r1 && typeof r1.totalElements === 'number') {
      $('#kpiProvActivos').textContent = r1.totalElements;
      return;
    }
    // fallback: página grande y contar
    const r2 = await ntGet(`${API_PROV}?activo=true&page=0&size=1000`);
    const count = Array.isArray(r2?.content) ? r2.content.length : (Array.isArray(r2) ? r2.length : 0);
    $('#kpiProvActivos').textContent = count || '--';
  } catch (e) {
    showToast(`KPI Proveedores: ${e.message}`, 'error', 'Dashboard');
    $('#kpiProvActivos').textContent = '--';
  }
}

async function ultimosProveedores(limit=3) {
  const tb = $('#tblUltimosProv'); tb.innerHTML = '';
  try {
    // Intentamos varios patrones habituales
    // a) endpoint con sort/size
    let data;
    try {
      data = await ntGet(`${API_PROV}?page=0&size=${limit}&sort=id,desc`);
    } catch { /* silencio: probamos otra forma */ }

    // b) endpoint custom /ultimos
    if (!data) {
      try { data = await ntGet(`${API_PROV}/ultimos?limit=${limit}`); } catch {}
    }

    // c) fallback: pedimos muchos y ordenamos por id desc nosotros
    if (!data) {
      data = await ntGet(`${API_PROV}?page=0&size=1000`);
      const arr = Array.isArray(data?.content) ? data.content : (Array.isArray(data) ? data : []);
      arr.sort((a,b)=> (b.id||0)-(a.id||0));
      data = { content: arr.slice(0, limit) };
    }

    const items = Array.isArray(data?.content) ? data.content : (Array.isArray(data) ? data : []);
    items.forEach(p=>{
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${ntEsc(p.codigo||'')}</td>
        <td>${ntEsc(p.nombre||'')}</td>
        <td>${ntEsc(p.nit||'')}</td>
        <td>${ntEsc(p.telefono||'')}</td>
        <td>${p.diasCredito ?? ''}</td>
      `;
      tb.appendChild(tr);
    });
    if (!items.length) {
      const tr = document.createElement('tr');
      tr.innerHTML = `<td colspan="5" class="text-center text-muted py-3">Sin datos</td>`;
      tb.appendChild(tr);
    }
  } catch (e) {
    showToast(`Últimos proveedores: ${e.message}`, 'error', 'Dashboard');
    const tr = document.createElement('tr');
    tr.innerHTML = `<td colspan="5" class="text-center text-muted py-3">Error</td>`;
    tb.appendChild(tr);
  }
}

// ====== Compras: KPI (mes), últimas N y gráfico 6 semanas ======
function ymd(d){ return d.toISOString().slice(0,10); }

async function comprasMes() {
  try {
    const hoy = new Date();
    const inicioMes = new Date(hoy.getFullYear(), hoy.getMonth(), 1);
    const url = `${API_COMP}?fechaDel=${ymd(inicioMes)}&fechaAl=${ymd(hoy)}`;
    const lista = await ntGet(url); // esperamos array de CompraListItem
    const total = (lista||[]).reduce((acc, it)=> acc + (Number(it.total)||0), 0);
    $('#kpiComprasMes').textContent = (lista||[]).length;
    $('#kpiComprasMesTotal').textContent = fmtMoney(total);
  } catch (e) {
    showToast(`Compras (mes): ${e.message}`, 'error', 'Dashboard');
    $('#kpiComprasMes').textContent = '--';
    $('#kpiComprasMesTotal').textContent = '--';
  }
}

async function ultimasCompras(limit=3) {
  const tb = $('#tblUltimasCompras'); tb.innerHTML = '';
  try {
    const hoy = new Date();
    const hace30 = new Date(hoy.getTime() - 30*24*60*60*1000);
    const url = `${API_COMP}?fechaDel=${ymd(hace30)}&fechaAl=${ymd(hoy)}`;
    const lista = await ntGet(url);
    const arr = Array.isArray(lista) ? lista : [];
    // Ordenamos por fechaCompra (desc) e id desc como desempate
    arr.sort((a,b)=>{
      const fa = (a.fechaCompra||''); const fb = (b.fechaCompra||'');
      if (fa>fb) return -1; if (fa<fb) return 1;
      return (b.id||0)-(a.id||0);
    });
    arr.slice(0,limit).forEach((c,i)=>{
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${i+1}</td>
        <td><span class="fw-semibold">${ntEsc(c.numeroCompra||'')}</span></td>
        <td>${ntEsc(c.fechaCompra||'')}</td>
        <td>${ntEsc(c.proveedorNombre||'')}</td>
        <td class="text-end">Q${fmtMoney(c.total)}</td>
        <td><span class="badge ${c.estado==='P'?'bg-secondary':c.estado==='R'?'bg-info':c.estado==='C'?'bg-success':'bg-danger'}">${c.estado||'-'}</span></td>
      `;
      tb.appendChild(tr);
    });
    if (!arr.length) {
      const tr = document.createElement('tr');
      tr.innerHTML = `<td colspan="6" class="text-center text-muted py-3">Sin compras recientes</td>`;
      tb.appendChild(tr);
    }
  } catch (e) {
    showToast(`Últimas compras: ${e.message}`, 'error', 'Dashboard');
    const tr = document.createElement('tr');
    tr.innerHTML = `<td colspan="6" class="text-center text-muted py-3">Error</td>`;
    tb.appendChild(tr);
  }
}

async function chartCompras6Semanas() {
  try {
    // Traemos 42 días (6 semanas) y agregamos en el cliente
    const hoy = new Date();
    const desde = new Date(hoy.getTime() - 41*24*60*60*1000);
    const lista = await ntGet(`${API_COMP}?fechaDel=${ymd(desde)}&fechaAl=${ymd(hoy)}`);
    const porDia = {};
    (lista||[]).forEach(it=>{
      const f = (it.fechaCompra || '').slice(0,10);
      if (!f) return;
      porDia[f] = (porDia[f]||0) + (Number(it.total)||0);
    });
    // labels: todos los días en rango, agrupando por semana (Lun..Dom) para 6 puntos
    const dias = [];
    for (let d = new Date(desde); d <= hoy; d.setDate(d.getDate()+1)) {
      dias.push(ymd(d));
    }
    // agrupamos en semanas de 7
    const labels = [];
    const data = [];
    for (let i=0; i<dias.length; i+=7){
      const slice = dias.slice(i,i+7);
      const suma = slice.reduce((acc, ymd)=> acc + (porDia[ymd]||0), 0);
      const etiqueta = `${slice[0].slice(5)}–${slice[slice.length-1].slice(5)}`;
      labels.push(etiqueta);
      data.push(Number(suma.toFixed(2)));
    }

    const ctx = document.getElementById('chartCompras');
    if (!ctx) return;

    // destruye previo si existe (por refrescar)
    if (window._chartCompras) { window._chartCompras.destroy(); }

    window._chartCompras = new Chart(ctx, {
      type: 'line',
      data: {
        labels,
        datasets: [{
          label: 'Total Q por semana',
          data
          // *No* setear colores — los defaults de Chart.js + tema oscuro quedan bien
        }]
      },
      options: {
        responsive: true,
        interaction: { mode: 'index', intersect: false },
        plugins: {
          legend: { labels: { color: '#dfe3ee' } },
          tooltip: {
            callbacks: { label: (ctx)=> ` Q ${fmtMoney(ctx.parsed.y)}` }
          }
        },
        scales: {
          x: { ticks: { color: '#c4c8d3' }, grid: { color: 'rgba(255,255,255,.06)' } },
          y: { ticks: { color: '#c4c8d3' }, grid: { color: 'rgba(255,255,255,.06)' } }
        }
      }
    });
  } catch (e) {
    showToast(`Gráfico compras: ${e.message}`, 'error', 'Dashboard');
  }
}

// ====== Orquestación ======
async function cargarDashboard() {
  await Promise.all([
    kpiProveedoresActivos(),
    comprasMes(),
    ultimosProveedores(3),
    ultimasCompras(3),
    chartCompras6Semanas()
  ]);
}

function bindUI(){
  $('#btnRefrescar')?.addEventListener('click', cargarDashboard);
}

window.addEventListener('DOMContentLoaded', ()=>{
  bindUI();
  cargarDashboard();
});
