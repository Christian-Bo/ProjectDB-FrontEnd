<%-- 
    Document   : index
    Created on : 9/10/2025, 22:56:53
    Author     : Christian
--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Iniciar sesión</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- Paleta global -->
  <link rel="stylesheet" href="assets/css/base.css">

  <!-- Bootstrap 5 + Fuente -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">

  <!-- Estilos específicos del login (sin colores) -->
  <link rel="stylesheet" href="assets/css/login.css">
</head> 
<body class="nt-bg">

<main class="min-vh-100 d-flex align-items-center justify-content-center nt-bg">
  <div class="auth-card nt-card">
    <div class="row g-0">
      <!-- HERO -->
      <aside class="col-lg-6 d-none d-lg-flex hero p-4">
        <div class="d-flex align-items-start justify-content-between w-100">
          <span class="badge brand-badge">Nextech</span>
        </div>
        <div class="hero-copy">
          <h1 class="display-6 fw-bold mb-2 text-white">Explorando nuevas fronteras, un paso a la vez.</h1>
          <p class="lead mb-0 text-white-50">Más allá del alcance de la Tierra</p>
        </div>
      </aside>

      <!-- FORM -->
      <section class="col-12 col-lg-6 bg-white form-pane">
        <div class="p-4 p-lg-5 h-100 d-flex flex-column justify-content-center">
          <div class="d-flex justify-content-end small mb-2">
            <span class="nt-subtitle me-1">¿No tienes cuenta?</span>
            <a class="nt-link" href="${pageContext.request.contextPath}/register.jsp">Regístrate</a>
          </div>

          <h2 class="nt-title mb-3">Iniciar sesión</h2>

          <div id="toastContainer"></div>

          <!-- Formulario de solo UI (no se envía) -->
          <form id="loginForm" onsubmit="return false;">
            <div class="mb-3">
              <label class="form-label">Correo o Usuario</label>
              <input type="text" class="form-control form-control-lg" id="username" name="username"
                     placeholder="tucorreo@empresa.com" autocomplete="username">
            </div>

            <div class="mb-3">
              <label class="form-label">Contraseña</label>
              <div class="position-relative">
                <input type="password" class="form-control form-control-lg" id="password" name="password"
                       placeholder="Tu contraseña" autocomplete="current-password">
                <button type="button" class="btn btn-sm btn-toggle-eye" id="togglePwd" aria-label="Mostrar/Ocultar">👁️</button>
              </div>
            </div>

            <div class="d-flex align-items-center justify-content-between mb-3">
              <div class="form-check">
                <input class="form-check-input" type="checkbox" id="remember" name="remember">
                <label class="form-check-label nt-subtitle" for="remember">Recordarme</label>
              </div>
              <a class="nt-link" href="#">¿Olvidaste tu contraseña?</a>
            </div>

            <!-- Botón que redirige directo al Dashboard -->
            <button type="button" id="goDash" class="btn btn-accent btn-lg w-100">Iniciar sesión</button>
          </form>
        </div>
      </section>
    </div>
  </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
  // Mostrar/ocultar contraseña (opcional, UI)
  (function(){
    const pwd = document.getElementById('password');
    const btn = document.getElementById('togglePwd');
    btn.addEventListener('click', () => {
      const isPwd = pwd.type === 'password';
      pwd.type = isPwd ? 'text' : 'password';
      btn.textContent = isPwd ? '🙈' : '👁️';
    });
  })();

  // Redirección directa al dashboard SIN validar nada
  (function(){
    document.getElementById('goDash').addEventListener('click', function(){
      window.location.href = '<%= request.getContextPath() %>/Dashboard.jsp';
      // Alternativa sin scriptlet:
      // window.location.href = '${pageContext.request.contextPath}/Dashboard.jsp';
    });
  })();
</script>

</body>
</html>
