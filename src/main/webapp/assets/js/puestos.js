/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */


(function (global) {
  const { baseUrl, http, showToast, loadDashboardKPIs, loadDepartamentosCatalog, loadPuestosCatalog } = global.NT;

  let modalPuesto;

  function ensureModal() {
    if (!modalPuesto) modalPuesto = new bootstrap.Modal('#modalPuesto');
    return modalPuesto;
  }

  function bindToolbar() {
    const btnNuevo = document.getElementById('btnPuestoNuevo');
    if (btnNuevo) btnNuevo.addEventListener('click', async () => {
      await fillDeptoCombo('puestoDepto');
      document.getElementById('puestoId').value = '';
      document.getElementById('puestoNombre').value = '';
      document.getElementById('puestoDepto').value = '';
      document.getElementById('puestoDesc').value = '';
      document.getElementById('puestoActivo').value = 'true';
      document.getElementById('modalPuestoTitle').innerText = 'Nuevo puesto';
      ensureModal().show();
    });

    const deptoFilter = document.getElementById('puestoDeptoFilter');
    if (deptoFilter) {
      fillDeptoCombo('puestoDeptoFilter', true);
      deptoFilter.addEventListener('change', () => renderPuestos());
    }
  }

  async function fillDeptoCombo(id, keepFirst = false) {
    const sel = document.getElementById(id);
    if (!sel) return;
    const list = await loadDepartamentosCatalog();
    if (!keepFirst) sel.innerHTML = '';
    if (keepFirst) /* mantiene la opción existente */ 0;
    else {
      const op0 = document.createElement('option');
      op0.value = ''; op0.textContent = 'Departamento';
      sel.appendChild(op0);
    }
    list.forEach(d => {
      const o = document.createElement('option');
      o.value = d.id; o.textContent = d.nombre; sel.appendChild(o);
    });
  }

  async function renderPuestos() {
    const depId = document.getElementById('puestoDeptoFilter')?.value || null;
    const list = await loadPuestosCatalog(depId || null);

    const tbody = document.getElementById('puestosTableBody');
    if (!tbody) return;
    tbody.innerHTML = '';
    list.forEach(p => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${p.nombre || ''}</td>
        <td>${p.departamentoNombre || ''}</td>
        <td><span class="badge ${p.activo ? 'bg-success' : 'bg-secondary'}">${p.activo ? 'Activo' : 'Inactivo'}</span></td>
        <td class="text-end">
          <button class="btn btn-sm btn-light me-2" data-edit-puesto="${p.id}">Editar</button>
          <button class="btn btn-sm btn-danger" data-del-puesto="${p.id}">Eliminar</button>
        </td>`;
      tbody.appendChild(tr);
    });
    const info = document.getElementById('puestosResultInfo');
    if (info) info.innerText = `${list.length} puesto(s)`;
  }

  function bindTabla() {
    const tbody = document.getElementById('puestosTableBody');
    if (!tbody) return;
    tbody.addEventListener('click', async (ev) => {
      const editId = ev.target.getAttribute('data-edit-puesto');
      const delId = ev.target.getAttribute('data-del-puesto');
      if (editId) {
        await fillDeptoCombo('puestoDepto');
        const list = await loadPuestosCatalog();
        const p = list.find(x => String(x.id) === String(editId));
        if (!p) return showToast('Puestos', 'No encontrado', 'error');
        document.getElementById('puestoId').value = p.id;
        document.getElementById('puestoNombre').value = p.nombre || '';
        document.getElementById('puestoDepto').value = p.departamentoId || '';
        document.getElementById('puestoDesc').value = p.descripcion || '';
        document.getElementById('puestoActivo').value = String(!!p.activo);
        document.getElementById('modalPuestoTitle').innerText = 'Editar puesto';
        ensureModal().show();
      } else if (delId) {
        if (!confirm('¿Eliminar puesto?')) return;
        await http(`${baseUrl}/api/rrhh/puestos/${delId}`, { method: 'DELETE' });
        showToast('Puestos', 'Puesto eliminado', 'success');
        await renderPuestos();
        await loadDashboardKPIs();
      }
    });
  }

  function bindModalSubmit() {
    const form = document.getElementById('formPuesto');
    if (!form) return;
    form.addEventListener('submit', async (ev) => {
      ev.preventDefault();
      const id = document.getElementById('puestoId').value || null;
      const body = {
        nombre: (document.getElementById('puestoNombre').value || '').trim(),
        descripcion: (document.getElementById('puestoDesc').value || '').trim() || null,
        activo: document.getElementById('puestoActivo').value === 'true',
        departamentoId: document.getElementById('puestoDepto').value ? parseInt(document.getElementById('puestoDepto').value) : null
      };
      const url = id ? `${baseUrl}/api/rrhh/puestos/${id}` : `${baseUrl}/api/rrhh/puestos`;
      const method = id ? 'PUT' : 'POST';
      try {
        await http(url, { method, body: JSON.stringify(body) });
        ensureModal().hide();
        showToast('Puestos', `Puesto ${id ? 'actualizado' : 'creado'}`, 'success');
        await renderPuestos();
        await loadDashboardKPIs();
      } catch (e) {
        showToast('Puestos', e.message, 'error');
      }
    });
  }

  async function initPuestos() {
    bindToolbar();
    bindTabla();
    bindModalSubmit();
    await fillDeptoCombo('puestoDeptoFilter', true);
    await renderPuestos();
  }

  global.RRHH_Puestos = { initPuestos, renderPuestos };
})(window);
