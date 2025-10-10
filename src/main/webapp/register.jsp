<%-- 
    Document   : register
    Created on : 9/10/2025, 23:52:25
    Author     : Christian
--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Crear cuenta</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <link rel="stylesheet" href="assets/css/base.css">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="assets/css/register.css">
</head>
<body class="nt-bg">

<main class="min-vh-100 d-flex align-items-center justify-content-center nt-bg">
  <div class="signup-card nt-card">
    <div class="row g-0">
      <!-- HERO/Imagen -->
      <aside class="col-lg-6 d-none d-lg-flex signup-hero p-4">
        <div class="d-flex align-items-start justify-content-between w-100">
          <span class="badge brand-badge">Nextech</span>
        </div>
        <div class="hero-copy">
          <h1 class="display-6 fw-bold mb-2 text-white">Crea tu cuenta</h1>
          <p class="lead mb-0 text-white-50">Accede a la plataforma</p>
        </div>
      </aside>

      <!-- FORM -->
      <section class="col-12 col-lg-6 bg-white form-pane">
        <div class="p-4 p-lg-5 h-100 d-flex flex-column justify-content-center">
          <div class="d-flex justify-content-end small mb-2">
            <span class="nt-subtitle me-1">¿Ya tienes cuenta?</span>
            <a class="nt-link" href="${pageContext.request.contextPath}/index.jsp">Inicia sesión</a>
          </div>

          <h2 class="nt-title mb-3">Registro de usuario</h2>

          <form id="registerForm" method="post" action="${pageContext.request.contextPath}/auth/register" novalidate>
            <%-- 
              TODO backend (sin JWT):
              - Validar unicidad de nombre_usuario.
              - Hash de contraseña.
              - Insert en dbo.usuarios (empleado_id y rol_id válidos).
              - Auditoría (I) en dbo.auditoria.
            --%>

            <div class="mb-3">
              <label class="form-label" for="nombre_usuario">Nombre de usuario</label>
              <input type="text" class="form-control form-control-lg" id="nombre_usuario" name="nombre_usuario" minlength="3" required>
              <div class="invalid-feedback">Mínimo 3 caracteres.</div>
            </div>

            <div class="mb-3">
              <label class="form-label" for="password">Contraseña</label>
              <input type="password" class="form-control form-control-lg" id="password" name="password" minlength="8" required>
              <div class="invalid-feedback">Mínimo 8 caracteres.</div>
            </div>

            <div class="mb-3">
              <label class="form-label" for="password2">Confirmar contraseña</label>
              <input type="password" class="form-control form-control-lg" id="password2" name="password2" minlength="8" required>
              <div class="invalid-feedback">Las contraseñas no coinciden.</div>
            </div>

            <div class="mb-3">
              <label class="form-label" for="empleado_id">Empleado</label>
              <select class="form-select form-select-lg" id="empleado_id" name="empleado_id" required>
                <option value="" selected disabled>Selecciona un empleado</option>
                <%-- TODO: poblar desde dbo.empleados --%>
                <option value="1">[Ejemplo] EMP-0001 — Juan Pérez</option>
              </select>
              <div class="invalid-feedback">Selecciona un empleado.</div>
            </div>

            <div class="mb-4">
              <label class="form-label" for="rol_id">Rol</label>
              <select class="form-select form-select-lg" id="rol_id" name="rol_id" required>
                <option value="" selected disabled>Selecciona un rol</option>
                <%-- TODO: poblar desde dbo.roles --%>
                <option value="1">[Ejemplo] Administrador</option>
                <option value="2">Operador</option>
              </select>
              <div class="invalid-feedback">Selecciona un rol.</div>
            </div>

            <div class="form-check mb-3">
              <input class="form-check-input" type="checkbox" id="terms" required>
              <label class="form-check-label nt-subtitle" for="terms">
                Acepto los términos y la política de privacidad
              </label>
              <div class="invalid-feedback d-block" style="display:none">Debes aceptar los términos.</div>
            </div>

            <button class="btn btn-accent btn-lg w-100" type="submit">Crear cuenta</button>
          </form>
        </div>
      </section>
    </div>
  </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  // Validación básica del cliente
  (function(){
    const form = document.getElementById('registerForm');
    form.addEventListener('submit', (e) => {
      let ok = true;

      const u = document.getElementById('nombre_usuario');
      const p1 = document.getElementById('password');
      const p2 = document.getElementById('password2');
      const emp = document.getElementById('empleado_id');
      const rol = document.getElementById('rol_id');
      const terms = document.getElementById('terms');

      // limpiar
      [u,p1,p2,emp,rol].forEach(el => el.classList.remove('is-invalid'));

      if (!u.value || u.value.length < 3){ ok = false; u.classList.add('is-invalid'); }
      if (!p1.value || p1.value.length < 8){ ok = false; p1.classList.add('is-invalid'); }
      if (!p2.value || p2.value.length < 8 || p2.value !== p1.value){ ok = false; p2.classList.add('is-invalid'); }
      if (!emp.value){ ok = false; emp.classList.add('is-invalid'); }
      if (!rol.value){ ok = false; rol.classList.add('is-invalid'); }
      if (!terms.checked){ ok = false; }

      if (!ok) e.preventDefault();
    });
  })();
</script>
</body>
</html>
