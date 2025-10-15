<%-- 
    Document   : puestos
    Created on : 13/10/2025, 01:33:34
    Author     : Christian
--%>

<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<!-- Toolbar Puestos -->
<div class="d-flex flex-wrap nt-toolbar">
  <select id="puestoDeptoFilter" class="form-select" style="max-width: 260px;">
    <option value="">Departamento</option>
  </select>
  <div class="flex-grow-1"></div>
  <button id="btnPuestoNuevo" class="btn btn-success">Nuevo puesto</button>
</div>
<div class="nt-divider"></div>

<!-- Tabla Puestos -->
<div class="card">
  <div class="card-header fw-semibold">Listado de puestos</div>
  <div class="card-body p-0">
    <div class="table-responsive">
      <table class="table table-hover mb-0">
        <thead class="nt-table-head">
          <tr>
            <th>Nombre</th>
            <th>Departamento</th>
            <th>Estado</th>
            <th class="text-end">Acciones</th>
          </tr>
        </thead>
        <tbody id="puestosTableBody"><!-- rows --></tbody>
      </table>
    </div>
  </div>
  <div class="card-footer small text-muted" id="puestosResultInfo"></div>
</div>

<!-- Modal Puesto -->
<div class="modal fade" id="modalPuesto" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <form id="formPuesto" class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="modalPuestoTitle">Nuevo puesto</h5>
        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="puestoId">
        <div class="mb-3">
          <label class="form-label">Nombre</label>
          <input id="puestoNombre" class="form-control" required>
        </div>
        <div class="mb-3">
          <label class="form-label">Departamento</label>
          <select id="puestoDepto" class="form-select" required></select>
        </div>
        <div class="mb-3">
          <label class="form-label">Descripción</label>
          <textarea id="puestoDesc" class="form-control" rows="3"></textarea>
        </div>
        <div class="mb-3">
          <label class="form-label">Activo</label>
          <select id="puestoActivo" class="form-select">
            <option value="true" selected>Sí</option>
            <option value="false">No</option>
          </select>
        </div>
      </div>
      <div class="modal-footer">
        <button data-bs-dismiss="modal" type="button" class="btn btn-outline-secondary">Cancelar</button>
        <button id="btnGuardarPuesto" type="submit" class="btn btn-primary">Guardar</button>
      </div>
    </form>
  </div>
</div>
