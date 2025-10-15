<%-- 
    Document   : empleados
    Created on : 13/10/2025, 01:32:48
    Author     : Christian
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!-- Toolbar Empleados -->
<div class="d-flex flex-wrap nt-toolbar">
  <input id="empSearch" class="form-control" placeholder="Buscar por nombre o apellido" style="max-width: 320px;">
  <select id="empEstado" class="form-select" style="max-width: 160px;">
    <option value="">Estado</option>
    <option value="A">Activo</option>
    <option value="I">Inactivo</option>
    <option value="S">Suspendido</option>
  </select>
  <select id="empDepto" class="form-select" style="max-width: 260px;">
    <option value="">Departamento</option>
  </select>
  <select id="empPuesto" class="form-select" style="max-width: 260px;">
    <option value="">Puesto</option>
  </select>
  <button id="btnEmpBuscar" class="btn btn-primary">Buscar</button>
  <div class="flex-grow-1"></div>
  <button id="btnEmpNuevo" class="btn btn-success">Nuevo empleado</button>
</div>
<div class="nt-divider"></div>

<!-- Tabla Empleados -->
<div class="card">
  <div class="card-header d-flex align-items-center justify-content-between">
    <span class="fw-semibold">Listado de empleados</span>
    <div class="small text-muted" id="empResultInfo"></div>
  </div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="nt-table-head">
          <tr>
            <th class="sticky">Código</th>
            <th class="sticky">Nombre</th>
            <th class="sticky">DPI</th>
            <th class="sticky">Puesto</th>
            <th class="sticky">Departamento</th>
            <th class="sticky">Estado</th>
            <th class="sticky text-end">Acciones</th>
          </tr>
        </thead>
        <tbody id="empTableBody"><!-- rows --></tbody>
      </table>
    </div>
  </div>
  <div class="card-footer">
    <nav><ul id="empPagination" class="pagination pagination-sm mb-0"></ul></nav>
  </div>
</div>

<!-- Modal Empleado -->
<div class="modal fade" id="modalEmpleado" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <form id="formEmpleado" class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="modalEmpleadoTitle">Nuevo empleado</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>
      <div class="modal-body">
        <div class="row g-3">
          <input type="hidden" id="empId">

          <div class="col-md-3">
            <label class="form-label">Código</label>
            <input id="empCodigo" class="form-control" required>
          </div>
          <div class="col-md-5">
            <label class="form-label">Nombres</label>
            <input id="empNombres" class="form-control" required>
          </div>
          <div class="col-md-4">
            <label class="form-label">Apellidos</label>
            <input id="empApellidos" class="form-control" required>
          </div>

          <div class="col-md-4">
            <label class="form-label">DPI</label>
            <input id="empDpi" class="form-control" required minlength="6" maxlength="13">
          </div>
          <div class="col-md-4">
            <label class="form-label">NIT</label>
            <input id="empNit" class="form-control">
          </div>
          <div class="col-md-4">
            <label class="form-label">Teléfono</label>
            <input id="empTelefono" class="form-control">
          </div>

          <div class="col-md-6">
            <label class="form-label">Email</label>
            <input id="empEmail" class="form-control">
          </div>
          <div class="col-md-6">
            <label class="form-label">Dirección</label>
            <input id="empDireccion" class="form-control">
          </div>

          <div class="col-md-4">
            <label class="form-label">Fecha ingreso</label>
            <input id="empFechaIngreso" type="date" class="form-control" required>
          </div>
          <div class="col-md-4">
            <label class="form-label">Fecha nacimiento</label>
            <input id="empFechaNac" type="date" class="form-control">
          </div>
          <div class="col-md-4">
            <label class="form-label">Estado</label>
            <select id="empEstadoEdit" class="form-select">
              <option value="A" selected>Activo</option>
              <option value="I">Inactivo</option>
              <option value="S">Suspendido</option>
            </select>
          </div>

          <div class="col-md-6">
            <label class="form-label">Departamento</label>
            <select id="empDeptoEdit" class="form-select" required></select>
          </div>
          <div class="col-md-6">
            <label class="form-label">Puesto</label>
            <select id="empPuestoEdit" class="form-select" required></select>
          </div>

          <div class="col-md-6">
            <label class="form-label">Jefe inmediato</label>
            <select id="empJefe" class="form-select"></select>
          </div>
          <div class="col-md-6">
            <label class="form-label">Foto (URL)</label>
            <input id="empFoto" class="form-control">
          </div>

        </div>
      </div>
      <div class="modal-footer">
        <button data-bs-dismiss="modal" type="button" class="btn btn-outline-secondary">Cancelar</button>
        <button id="btnGuardarEmpleado" type="submit" class="btn btn-primary">Guardar</button>
      </div>
    </form>
  </div>
</div>
