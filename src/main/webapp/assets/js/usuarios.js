(() => {
  const API_BASE = localStorage.getItem('api_base') || 'http://localhost:8080';
  const AUTH_TOKEN = localStorage.getItem('auth_token') || '';

  // --- elementos
  const tbody = document.getElementById('tblUsuariosBody');
  const info = document.getElementById('usuariosInfo');
  const pager = document.getElementById('usuariosPager');
  const search = document.getElementById('userSearch');
  const btnNew = document.getElementById('btnNewUser');

  // modal
  const modalEl = document.getElementById('modalUsuario');
  const modal = modalEl ? new bootstrap.Modal(modalEl) : null;
  const title = document.getElementById('modalUsuarioTitle');
  const userId = document.getElementById('userId');
  const nombreUsuario = document.getElementById('nombreUsuario');
  const password = document.getElementById('password');
  const estado = document.getElementById('estado');
  const empleadoSelect = document.getElementById('empleadoSelect');
  const rolSelect = document.getElementById('rolSelect');
  const btnSave = document.getElementById('btnSaveUsuario');

  let state = { page: 0, size: 10, sort: 'id,desc', q: '' };
  let empleadosCache = []; // {id, label}
  let rolesCache = [];     // {id, nombre}

  function headers() {
    const h = { 'Content-Type': 'application/json' };
    if (AUTH_TOKEN) h['Authorization'] = 'Bearer ' + AUTH_TOKEN;
    return h;
  }

  function badgeEstado(s) {
    if (s === 'A') return '<span class="badge bg-success">Activo</span>';
    if (s === 'I') return '<span class="badge bg-secondary">Inactivo</span>';
    if (s === 'B') return '<span class="badge bg-warning text-dark">Bloqueado</span>';
    return '<span class="badge bg-secondary">?</span>';
  }

  async function loadEmpleadosLite() {
    const url = new URL('/api/rrhh/empleados', API_BASE);
    url.searchParams.set('page', '0');
    url.searchParams.set('size', '200');
    url.searchParams.set('sort', 'nombres,asc');

    const resp = await fetch(url, { headers: headers() });
    if (!resp.ok) {
      empleadoSelect.innerHTML = `<option value="">Error al cargar empleados</option>`;
      return;
    }
    const data = await resp.json();
    empleadosCache = (data.content || []).map(e => ({
      id: e.id,
      label: `${e.codigo ?? ''} - ${e.nombres} ${e.apellidos} (#${e.id})`.trim()
    }));
    empleadoSelect.innerHTML = `<option value="">Seleccione…</option>` +
      empleadosCache.map(e => `<option value="${e.id}">${e.label}</option>`).join('');
  }

  async function loadRoles() {
    const url = new URL('/api/seg/roles', API_BASE);
    const resp = await fetch(url, { headers: headers() });
    if (!resp.ok) {
      rolSelect.innerHTML = `<option value="">Error al cargar roles</option>`;
      return;
    }
    rolesCache = await resp.json();
    rolSelect.innerHTML = `<option value="">Seleccione…</option>` +
      rolesCache.map(r => `<option value="${r.id}">${r.nombre}</option>`).join('');
  }

  async function loadList() {
    const url = new URL('/api/seg/usuarios', API_BASE);
    url.searchParams.set('page', state.page);
    url.searchParams.set('size', state.size);
    url.searchParams.set('sort', state.sort);
    if (state.q) url.searchParams.set('q', state.q);

    const resp = await fetch(url, { headers: headers() });
    if (!resp.ok) {
      tbody.innerHTML = `<tr><td colspan="7" class="text-danger">Error ${resp.status} al cargar usuarios</td></tr>`;
      info.textContent = '';
      pager.innerHTML = '';
      return;
    }
    const data = await resp.json();

    tbody.innerHTML = (data.content || []).map(u => `
      <tr>
        <td>${u.id}</td>
        <td>${u.nombreUsuario}</td>
        <td>${badgeEstado(u.estado)}</td>
        <td>${u.empleadoNombreCompleto ? u.empleadoNombreCompleto : (u.empleadoId ? ('#'+u.empleadoId) : '')}</td>
        <td>${u.rolNombre ?? (u.rolId ? ('#'+u.rolId) : '')}</td>
        <td>${u.ultimoAcceso ?? ''}</td>
        <td class="text-end">
          <button class="btn btn-sm btn-icon btn-icon-light me-1" title="Editar" data-act="edit" data-id="${u.id}">
            <i class="bi bi-pencil"></i>
          </button>
          <button class="btn btn-sm btn-icon btn-icon-warning" title="Inactivar" data-act="del" data-id="${u.id}">
            <i class="bi bi-x-lg"></i>
          </button>
        </td>
      </tr>
    `).join('');

    info.textContent = `Mostrando ${data.number + 1}/${data.totalPages} · Total ${data.totalElements}`;
    renderPager(data);
  }

  function renderPager(p) {
    if (!pager) return;
    const { number, totalPages } = p;
    let html = '';
    const prevDisabled = number <= 0 ? 'disabled' : '';
    const nextDisabled = number >= totalPages - 1 ? 'disabled' : '';

    html += `<li class="page-item ${prevDisabled}"><a class="page-link" href="#" data-go="${number - 1}">«</a></li>`;
    const start = Math.max(0, number - 2);
    const end = Math.min(totalPages - 1, number + 2);
    for (let i = start; i <= end; i++) {
      html += `<li class="page-item ${i === number ? 'active' : ''}">
                 <a class="page-link" href="#" data-go="${i}">${i + 1}</a>
               </li>`;
    }
    html += `<li class="page-item ${nextDisabled}"><a class="page-link" href="#" data-go="${number + 1}">»</a></li>`;
    pager.innerHTML = html;
  }

  // Paginación
  pager?.addEventListener('click', (e) => {
    const a = e.target.closest('a[data-go]');
    if (!a) return;
    e.preventDefault();
    const go = parseInt(a.getAttribute('data-go'), 10);
    if (Number.isInteger(go) && go >= 0) {
      state.page = go;
      loadList();
    }
  });

  // Buscar
  search?.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
      state.q = search.value.trim();
      state.page = 0;
      loadList();
    }
  });

  // Nuevo
  btnNew?.addEventListener('click', async () => {
    title.textContent = 'Nuevo usuario';
    userId.value = '';
    nombreUsuario.value = '';
    password.value = '';
    estado.value = 'A';

    await Promise.all([loadEmpleadosLite(), loadRoles()]);
    empleadoSelect.value = '';
    rolSelect.value = '';

    modal?.show();
  });

  // Editar / Inactivar (delegado con closest)
  tbody?.addEventListener('click', async (e) => {
    const btn = e.target.closest('button[data-act]');
    if (!btn) return;
    const id = parseInt(btn.getAttribute('data-id'), 10);
    const act = btn.getAttribute('data-act');

    if (act === 'edit') {
      const url = new URL(`/api/seg/usuarios/${id}`, API_BASE);
      const [respUser] = await Promise.all([
        fetch(url, { headers: headers() }),
        loadEmpleadosLite(),
        loadRoles()
      ]);
      if (!respUser.ok) return alert('No se pudo cargar el usuario');
      const u = await respUser.json();

      title.textContent = `Editar usuario #${u.id}`;
      userId.value = u.id;
      nombreUsuario.value = u.nombreUsuario;
      password.value = ''; // vacío para no cambiar
      estado.value = u.estado ?? 'A';
      empleadoSelect.value = u.empleadoId ?? '';
      rolSelect.value = u.rolId ?? '';

      modal?.show();

    } else if (act === 'del') {
      if (!confirm(`¿Inactivar usuario #${id}?`)) return;
      const url = new URL(`/api/seg/usuarios/${id}/estado`, API_BASE);
      const resp = await fetch(url, {
        method: 'PATCH',
        headers: headers(),
        body: JSON.stringify({ estado: 'I' })
      });
      if (!resp.ok) return alert('No se pudo inactivar');
      loadList();
    }
  });

  // Guardar
  btnSave?.addEventListener('click', async () => {
    const id = userId.value ? parseInt(userId.value, 10) : null;
    const body = {
      nombreUsuario: nombreUsuario.value.trim(),
      empleadoId: empleadoSelect.value ? parseInt(empleadoSelect.value, 10) : null,
      rolId: rolSelect.value ? parseInt(rolSelect.value, 10) : null,
      estado: estado.value
    };
    let method = 'POST';
    let url = new URL('/api/seg/usuarios', API_BASE);

    if (id) {
      method = 'PUT';
      url = new URL(`/api/seg/usuarios/${id}`, API_BASE);
      if (password.value && password.value.trim()) {
        body.password = password.value;
      }
    } else {
      if (!password.value || !password.value.trim()) {
        return alert('Contraseña requerida para crear');
      }
      body.password = password.value;
    }

    const resp = await fetch(url, {
      method,
      headers: headers(),
      body: JSON.stringify(body)
    });

    if (!resp.ok) {
      const txt = await resp.text();
      alert('Error al guardar: ' + txt);
      return;
    }
    modal?.hide();
    loadList();
  });

  // inicial
  loadList();
})();
