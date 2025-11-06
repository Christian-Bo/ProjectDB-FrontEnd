/* Departamentos */
(function (global) {
  const { baseUrl, http, showToast, loadDashboardKPIs, loadDepartamentosCatalog } = global.NT;
  let modalDepto;

  function ensureModal() {
    if (!modalDepto) modalDepto = new bootstrap.Modal('#modalDepto');
    return modalDepto;
  }

  function bindToolbar() {
    const btnNuevo = document.getElementById('btnDeptoNuevo');
    if (btnNuevo) btnNuevo.addEventListener('click', () => {
      document.getElementById('deptoId').value = '';
      document.getElementById('deptoNombre').value = '';
      document.getElementById('deptoDesc').value = '';
      document.getElementById('deptoActivo').value = 'true';
      document.getElementById('modalDeptoTitle').innerText = 'Nuevo departamento';
      ensureModal().show();
    });
  }

  function bindTabla() {
    const tbody = document.getElementById('deptoTableBody');
    if (!tbody) return;

    tbody.addEventListener('click', async (ev) => {
      const editBtn = ev.target.closest('[data-edit-depto]');
      const delBtn  = ev.target.closest('[data-del-depto]');

      if (editBtn) {
        const editId = editBtn.getAttribute('data-edit-depto');
        const list = await loadDepartamentosCatalog();
        const d = list.find(x => String(x.id) === String(editId));
        if (!d) return showToast('Departamentos', 'No encontrado', 'error');

        document.getElementById('deptoId').value = d.id;
        document.getElementById('deptoNombre').value = d.nombre || '';
        document.getElementById('deptoDesc').value = d.descripcion || '';
        document.getElementById('deptoActivo').value = String(!!d.activo);
        document.getElementById('modalDeptoTitle').innerText = 'Editar departamento';
        ensureModal().show();
        return;
      }

      if (delBtn) {
        // Tu confirm bonito del JSP intercepta este click antes (capture:true).
        // Si por alguna razón no carga, usamos confirm nativo como fallback.
        const delId = delBtn.getAttribute('data-del-depto');
        if (!confirm('¿Eliminar departamento?')) return;
        await http(`${baseUrl}/api/rrhh/departamentos/${delId}`, { method: 'DELETE' });
        showToast('Departamentos', 'Departamento eliminado', 'success');
        await renderDepartamentos();
        await loadDashboardKPIs();
      }
    });
  }

  function bindModalSubmit() {
    const form = document.getElementById('formDepto');
    if (!form) return;
    form.addEventListener('submit', async (ev) => {
      ev.preventDefault();
      const id = document.getElementById('deptoId').value || null;
      const body = {
        nombre: (document.getElementById('deptoNombre').value || '').trim(),
        descripcion: (document.getElementById('deptoDesc').value || '').trim() || null,
        activo: document.getElementById('deptoActivo').value === 'true'
      };
      const url = id ? `${baseUrl}/api/rrhh/departamentos/${id}` : `${baseUrl}/api/rrhh/departamentos`;
      const method = id ? 'PUT' : 'POST';
      try {
        await http(url, { method, body: JSON.stringify(body) });
        ensureModal().hide();
        showToast('Departamentos', `Departamento ${id ? 'actualizado' : 'creado'}`, 'success');
        await renderDepartamentos();
        await loadDashboardKPIs();
      } catch (e) {
        showToast('Departamentos', e.message, 'error');
      }
    });
  }

  async function renderDepartamentos() {
    const list = await loadDepartamentosCatalog();
    const tbody = document.getElementById('deptoTableBody');
    if (!tbody) return;
    tbody.innerHTML = '';
    list.forEach(d => {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${d.nombre || ''}</td>
        <td>${d.descripcion || ''}</td>
        <td><span class="badge ${d.activo ? 'bg-success' : 'bg-secondary'}">${d.activo ? 'Activo' : 'Inactivo'}</span></td>
        <td class="text-end">
          <button class="btn btn-sm btn-icon btn-icon-light me-2" title="Editar" data-edit-depto="${d.id}">
            <i class="bi bi-pencil"></i>
          </button>
          <button class="btn btn-sm btn-icon btn-icon-danger" title="Eliminar" data-del-depto="${d.id}">
            <i class="bi bi-x-lg"></i>
          </button>
        </td>`;
      tbody.appendChild(tr);
    });
    const info = document.getElementById('deptoResultInfo');
    if (info) info.innerText = `${list.length} departamento(s)`;
  }

  async function initDepartamentos() {
    bindToolbar();
    bindTabla();
    bindModalSubmit();
    await renderDepartamentos();
  }

  global.RRHH_Departamentos = { initDepartamentos, renderDepartamentos };
})(window);
