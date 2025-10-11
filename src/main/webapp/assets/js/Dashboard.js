/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

// Dashboard — KPIs, últimas entidades y gráfico

// ====== Base de APIs (respeta <meta name="api-base"> o window.API_BASE) ======
const API_BASE = getApiBase();
const API_PROV = `${API_BASE}/api/proveedores`;      // ya lo venías usando
const API_COMP = `${API_BASE}/api/compras`;           // lista de compras existente
const API_CXP_DOC = `${API_BASE}/api/cxp/documentos`; // de CxpController
const API_CXP_PAG = `${API_BASE}/api/cxp/pagos`;      // de CxpController

// ====== Helpers de formato ======
const $  = (s,c=document)=>c.querySelector(s);
const $$ = (s,c=document)=>Array.from(c.querySelectorAll(s));
const fmtMoney = v => (v==null?'0.00':Number(v).toLocaleString('es-GT',{minimumFractionDigits:2, maximumFractionDigits:2}));
const ymd = (d)=> (d instanceof Date ? d.toISOString().slice(0,10) : String(d).slice(0,10));

// ====== KPI: Proveedores activos ======
async function kpiProveedoresActivos() {
  try {
    // 1) Intento de patrón paginado Spring (totalElements)
    const r1 = await ntGet(`${API_PROV}?activo=true&page=0&size=1`).catch(()=>null);
    if (r1 && typeof r1.totalElements === 'number') {
      $('#kpiProvActivos').textContent = r1.totalElements;
      return;
    }
    // 2) Fallback: traer page grande y contar
    const r2 = await ntGet(`${API_PROV}?activo=true&page=0&size=1000`).catch(()=>null);
    const arr = Array.isArray(r2?.content) ? r2.content : (Array.isArray(r2) ? r2 : []);
    $('#kpiProvActivos').textContent = arr.length || '--';
  } catch (e) {
    showToast(`KPI Proveedores: ${e.message}`, 'error', 'Dashboard');
    $('#kpiProvActivos').textContent = '--';
  }
}

// ====== KPIs de Compras y CxP ======
async function comprasMes() {
  try {
    const hoy = new Date();
    const inicioMes = new Date(hoy.getFullYear(), hoy.getMonth(), 1);
    const url = `${API_COMP}?fechaDel=${ymd(inicioMes)}&fechaAl=${ymd(hoy)}`;
    const lista = await ntGet(url); // array esperado
    const total = (lista||[]).reduce((acc, it)=> acc + (Number(it.total)||0), 0);
    $('#kpiComprasMes').textContent = (lista||[]).length;
    $('#kpiComprasMesTotal').textContent = fmtMoney(total);
  } catch (e) {
    showToast(`Compras (mes): ${e.message}`, 'error', 'Dashboard');
    $('#kpiComprasMes').textContent = '--';
    $('#kpiComprasMesTotal').textContent = '--';
  }
}

/** Suma saldos pendientes en documentos estado 'P' (pendiente) */
async function cxpSaldoPendiente() {
  try {
    // Traemos documentos recientes (o todos si tu SP lo permite con filtros nulos)
    const docs = await ntGet(`${API_CXP_DOC}?proveedorId=&texto=`); // ambos nulos -> sin filtros
    const arr = Array.isArray(docs) ? docs : [];
    const totalPend = arr
      .filter(d => (d.estado || '').toUpperCase().startsWith('P'))
      .reduce((acc, d)=> acc + (Number(d.saldo_pendiente)||0), 0);
    $('#kpiCxpPendiente').textContent = fmtMoney(totalPend);
  } catch (e) {
    showToast(`CxP pendiente: ${e.message}`, 'error', 'Dashboard');
    $('#kpiCxpPendiente').textContent = '--';
  }
}

/** Total de pagos de CxP del mes (sumatoria de monto_total) */
async function cxpPagosMes() {
  try {
    const hoy = new Date();
    const inicioMes = new Date(hoy.getFullYear(), hoy.getMonth(), 1);
    // Tu endpoint de pagos no recibe fechas, así que traemos los pagos y filtramos en el cliente
    const pagos = await ntGet(`${API_CXP_PAG}?proveedorId=&texto=`);
    const arr = Array.isArray(pagos) ? pagos : [];
    const desde = ymd(inicioMes);
    const hasta = ymd(hoy);
    const suma = arr
      .filter(p => {
        const f = ymd(p.fecha_pago);
        return f >= desde && f <= hasta;
      })
      .reduce((acc, p)=> acc + (Number(p.monto_total)||0), 0);
    $('#kpiPagosMes').textContent = fmtMoney(suma);
  } catch (e) {
    showToast(`Pagos CxP (mes): ${e.message}`, 'error', 'Dashboard');
    $('#kpiPagosMes').textContent = '--';
  }
}

// ====== Tablas: últimos proveedores, compras y pagos ======
async function ultimosProveedores(limit=3) {
  const tb = $('#tblUltimosProv'); tb.innerHTML = '';
  try {
    // a) Paginado con sort
    let data = await ntGet(`${API_PROV}?page=0&size=${limit}&sort=id,desc`).catch(()=>null);
    // b) Endpoint custom
    if (!data) data = await ntGet(`${API_PROV}/ultimos?limit=${limit}`).catch(()=>null);
    // c) Fallback: cargar grande y ordenar
    if (!data) {
      const all = await ntGet(`${API_PROV}?page=0&size=1000`).catch(()=>[]);
      const arr = Array.isArray(all?.content) ? all.content : (Array.isArray(all) ? all : []);
      arr.sort((a,b)=> (b.id||0)-(a.id||0));
      data = { content: arr.slice(0, limit) };
    }
    const items = Array.isArray(data?.content) ? data.content : (Array.isArray(data) ? data : []);
    if (!items.length) {
      tb.innerHTML = `<tr><td colspan="5" class="text-center text-muted py-3">Sin datos</td></tr>`;
      return;
    }
    items.forEach(p=>{
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${ntEsc(p.codigo||'')}</td>
        <td>${ntEsc(p.nombre||'')}</td>
        <td>${ntEsc(p.nit||'')}</td>
        <td>${ntEsc(p.telefono||'')}</td>
        <td>${p.diasCredito ?? ''}</td>`;
      tb.appendChild(tr);
    });
  } catch (e) {
    showToast(`Últimos proveedores: ${e.message}`, 'error', 'Dashboard');
    tb.innerHTML = `<tr><td colspan="5" class="text-center text-muted py-3">Error</td></tr>`;
  }
}

async function ultimasCompras(limit=3) {
  const tb = $('#tblUltimasCompras'); tb.innerHTML = '';
  try {
    const hoy = new Date();
    const hace30 = new Date(hoy.getTime() - 30*24*60*60*1000);
    const lista = await ntGet(`${API_COMP}?fechaDel=${ymd(hace30)}&fechaAl=${ymd(hoy)}`);
    const arr = Array.isArray(lista) ? lista : [];
    arr.sort((a,b)=>{
      const fa = (a.fechaCompra||''); const fb = (b.fechaCompra||'');
      if (fa>fb) return -1; if (fa<fb) return 1;
      return (b.id||0)-(a.id||0);
    });
    (arr.slice(0,limit)).forEach((c,i)=>{
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${i+1}</td>
        <td class="fw-semibold">${ntEsc(c.numeroCompra||'')}</td>
        <td>${ntEsc(c.fechaCompra||'')}</td>
        <td>${ntEsc(c.proveedorNombre||'')}</td>
        <td class="text-end">Q${fmtMoney(c.total)}</td>
        <td><span class="badge ${c.estado==='P'?'bg-secondary':c.estado==='R'?'bg-info':c.estado==='C'?'bg-success':'bg-danger'}">${c.estado||'-'}</span></td>`;
      tb.appendChild(tr);
    });
    if (!arr.length) {
      tb.innerHTML = `<tr><td colspan="6" class="text-center text-muted py-3">Sin compras recientes</td></tr>`;
    }
  } catch (e) {
    showToast(`Últimas compras: ${e.message}`, 'error', 'Dashboard');
    tb.innerHTML = `<tr><td colspan="6" class="text-center text-muted py-3">Error</td></tr>`;
  }
}

async function ultimosPagosCxp(limit=5) {
  const tb = $('#tblUltimosPagos'); tb.innerHTML = '';
  try {
    const pagos = await ntGet(`${API_CXP_PAG}?proveedorId=&texto=`);
    const arr = Array.isArray(pagos) ? pagos : [];
    // Ordena por fecha_pago desc, luego id desc
    arr.sort((a,b)=>{
      const fa = ymd(a.fecha_pago), fb = ymd(b.fecha_pago);
      if (fa>fb) return -1; if (fa<fb) return 1;
      return (b.id||0)-(a.id||0);
    });
    (arr.slice(0,limit)).forEach(p=>{
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="text-muted">#${p.id}</td>
        <td>${p.proveedor_id}</td>
        <td>${ntEsc(p.fecha_pago||'')}</td>
        <td>${ntEsc(p.forma_pago||'')}</td>
        <td class="text-end">Q${fmtMoney(p.monto_total)}</td>
        <td title="${ntEsc(p.observaciones||'')}">${ntEsc((p.observaciones||'').slice(0,40))}</td>`;
      tb.appendChild(tr);
    });
    if (!arr.length) {
      tb.innerHTML = `<tr><td colspan="6" class="text-center text-muted py-3">Sin pagos</td></tr>`;
    }
  } catch (e) {
    showToast(`Últimos pagos CxP: ${e.message}`, 'error', 'Dashboard');
    tb.innerHTML = `<tr><td colspan="6" class="text-center text-muted py-3">Error</td></tr>`;
  }
}

// ====== Gráfico: Compras últimas 6 semanas ======
async function chartCompras6Semanas() {
  try {
    const hoy = new Date();
    const desde = new Date(hoy.getTime() - 41*24*60*60*1000); // 42 días
    const lista = await ntGet(`${API_COMP}?fechaDel=${ymd(desde)}&fechaAl=${ymd(hoy)}`);
    const porDia = {};
    (lista||[]).forEach(it=>{
      const f = ymd(it.fechaCompra||'');
      if (!f) return;
      porDia[f] = (porDia[f]||0) + (Number(it.total)||0);
    });

    // labels: 6 semanas (7 días c/u)
    const dias = [];
    for (let d = new Date(desde); d <= hoy; d.setDate(d.getDate()+1)) dias.push(ymd(d));
    const labels = [], data = [];
    for (let i=0; i<dias.length; i+=7){
      const slice = dias.slice(i,i+7);
      const suma = slice.reduce((acc, y)=> acc + (porDia[y]||0), 0);
      labels.push(`${slice[0].slice(5)}–${slice[slice.length-1].slice(5)}`);
      data.push(Number(suma.toFixed(2)));
    }

    const ctx = document.getElementById('chartCompras');
    if (!ctx) return;

    if (window._chartCompras) window._chartCompras.destroy(); // por refrescos

    // *No* seteamos colores manualmente, para respetar estilos globales/tema
    window._chartCompras = new Chart(ctx, {
      type: 'line',
      data: { labels, datasets: [{ label: 'Total Q por semana', data }] },
      options: {
        responsive: true,
        interaction: { mode: 'index', intersect: false },
        plugins: {
          legend: { labels: { color: '#c4c8d3' } },
          tooltip: { callbacks: { label: (ctx)=> ` Q ${fmtMoney(ctx.parsed.y)}` } }
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
  await Promise.allSettled([
    kpiProveedoresActivos(),
    comprasMes(),
    cxpSaldoPendiente(),
    cxpPagosMes(),
    ultimosProveedores(3),
    ultimasCompras(3),
    ultimosPagosCxp(5),
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
