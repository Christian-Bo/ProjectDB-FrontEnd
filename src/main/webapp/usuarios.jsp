<%-- 
    Document   : usuarios
    Created on : 14/10/2025, 17:14:02
    Author     : Christian
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="card mt-2">
  <div class="card-header d-flex align-items-center justify-content-between">
    <span class="fw-semibold">Usuarios</span>
    <div class="d-flex gap-2">
      <input id="userSearch" type="search" class="form-control form-control-sm" placeholder="Buscar usuario...">
      <button id="btnNewUser" class="btn btn-primary btn-sm">Nuevo</button>
    </div>
  </div>
  <div class="card-body p-2">
    <div class="table-responsive">
      <table class="table table-hover align-middle mb-2">
        <thead class="nt-table-head">
          <tr>
            <th>ID</th>
            <th>Usuario</th>
            <th>Estado</th>
            <th>Empleado</th>
            <th>Rol</th>
            <th>Último acceso</th>
            <th></th>
          </tr>
        </thead>
        <tbody id="tblUsuariosBody"><!-- rows --></tbody>
      </table>
    </div>
    <nav class="d-flex justify-content-between align-items-center">
      <div class="small text-muted" id="usuariosInfo"></div>
      <ul class="pagination pagination-sm mb-0" id="usuariosPager"></ul>
    </nav>
  </div>
</div>

<!-- Modal Crear/Editar -->
<div class="modal fade" id="modalUsuario" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-dialog-centered modal-lg">
    <div class="modal-content">

      <div class="modal-header">
        <h5 class="modal-title" id="modalUsuarioTitle">Nuevo usuario</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>

      <div class="modal-body">
        <form id="frmUsuario" onsubmit="return false;">
          <input type="hidden" id="userId">

          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label">Usuario</label>
              <input type="text" id="nombreUsuario" class="form-control" required>
            </div>
            <div class="col-md-4">
              <label class="form-label">Contraseña</label>
              <input type="password" id="password" class="form-control" placeholder="••••••">
              <div class="form-text">Déjalo vacío para no cambiarla (en edición).</div>
            </div>
            <div class="col-md-4">
              <label class="form-label">Estado</label>
              <select id="estado" class="form-select">
                <option value="A">Activo</option>
                <option value="I">Inactivo</option>
                <option value="B">Bloqueado</option>
              </select>
            </div>

            <div class="col-md-6">
              <label class="form-label">Empleado</label>
              <!-- MOSTRAR NOMBRES -->
              <select id="empleadoSelect" class="form-select" required>
                <option value="">Cargando empleados…</option>
              </select>
              <div class="form-text">Proviene de RRHH → Empleados</div>
            </div>

            <div class="col-md-6">
              <label class="form-label">Rol</label>
              <!-- MOSTRAR NOMBRES -->
              <select id="rolSelect" class="form-select" required>
                <option value="">Cargando roles…</option>
              </select>
            </div>
          </div>

        </form>
      </div>

      <div class="modal-footer">
        <button id="btnSaveUsuario" class="btn btn-primary">Guardar</button>
        <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
      </div>

    </div>
  </div>
</div>
