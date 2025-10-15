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
  <title>Iniciar sesión • Nextech</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">

  <!-- Paleta global -->
  <link rel="stylesheet" href="assets/css/base.css">

  <!-- Bootstrap 5 + Fuente + Iconos -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Estilos específicos del login -->
  <link rel="stylesheet" href="assets/css/login.css">
</head> 
<body class="nt-bg">
  
<main class="min-vh-100 d-flex align-items-center justify-content-center nt-bg overflow-hidden">
  <!-- Fondo animado -->
  <div class="nt-orbits">
    <span class="nt-orbit nt-orbit-1"></span>
    <span class="nt-orbit nt-orbit-2"></span>
    <span class="nt-orbit nt-orbit-3"></span>
  </div>

  <div class="auth-card nt-card shadow-xxl">
    <div class="row g-0">
      <!-- HERO -->
      <aside class="col-lg-6 d-none d-lg-flex hero p-4 position-relative">
        <div class="d-flex align-items-start justify-content-between w-100">
          <span class="badge brand-badge">Nextech</span>
          <span class="badge env-badge"><i class="bi bi-cloud"></i> Cloud Ready</span>
        </div>
        <div class="hero-copy mt-auto pb-3">
          <h1 class="display-6 fw-bold mb-2 text-white">
            Más allá de los límites<span class="nt-caret">|</span>
          </h1>
          <p class="lead mb-0 text-white-50">
            Tecnología que impulsa tus decisiones.
          </p>
        </div>
        <!-- Glow decorativo -->
        <div class="hero-glow"></div>
      </aside>

      <!-- FORM -->
      <section class="col-12 col-lg-6 bg-white form-pane">
        <div class="p-4 p-lg-5 h-100 d-flex flex-column justify-content-center">
          <div class="d-flex justify-content-end small mb-2">
            <!-- Eliminado el link de "Regístrate" -->
          </div>

          <div class="d-flex align-items-center gap-2 mb-1">
            <div class="nt-logo">
              <i class="bi bi-kanban"></i>
            </div>
            <h2 class="nt-title mb-0">Bienvenido</h2>
          </div>
          <p class="nt-subtitle mb-4">Inicia sesión para acceder al panel</p>

          <div id="toastContainer" class="mb-2"></div>

          <form id="loginForm" onsubmit="return false;" novalidate>
            <!-- Usuario -->
            <div class="mb-3">
              <label class="form-label">Correo o Usuario</label>
              <div class="input-group input-group-lg nt-input">
                <span class="input-group-text"><i class="bi bi-person"></i></span>
                <input type="text" class="form-control" id="username" name="username"
                       placeholder="tucorreo@empresa.com" autocomplete="username" required>
              </div>
              <div class="invalid-feedback">Ingresa tu usuario o correo.</div>
            </div>

            <!-- Password -->
            <div class="mb-2">
              <label class="form-label">Contraseña</label>
              <div class="input-group input-group-lg nt-input position-relative">
                <span class="input-group-text"><i class="bi bi-shield-lock"></i></span>
                <input type="password" class="form-control" id="password" name="password"
                       placeholder="Tu contraseña" autocomplete="current-password" required>
                <button type="button" class="btn btn-toggle-eye" id="togglePwd" aria-label="Mostrar/Ocultar">
                  <i class="bi bi-eye"></i>
                </button>
              </div>
              <div class="invalid-feedback">Ingresa tu contraseña.</div>
            </div>

            <!-- Opciones -->
            <div class="d-flex align-items-center justify-content-between mb-4">
              <div class="form-check">
                <input class="form-check-input" type="checkbox" id="remember" name="remember">
                <label class="form-check-label nt-subtitle" for="remember">Recordarme</label>
              </div>
              <a class="nt-link" href="#" id="forgotLink">¿Olvidaste tu contraseña?</a>
            </div>

            <!-- Botón -->
            <button type="button" id="goDash" class="btn btn-accent btn-lg w-100 d-inline-flex align-items-center justify-content-center gap-2">
              <span class="btn-label"><i class="bi bi-box-arrow-in-right"></i> Iniciar sesión</span>
              <span class="btn-spinner spinner-border spinner-border-sm d-none" role="status" aria-hidden="true"></span>
            </button>
          </form>

          <!-- Nota legal -->
          <div class="text-center mt-4 small text-muted">
            <i class="bi bi-lock"></i> Conexión segura • Nextech © <span id="year"></span>
          </div>
        </div>
      </section>
    </div>
  </div>
</main>

<script>
  // API base (editable por localStorage)
  const API_BASE = localStorage.getItem('api_base') || 'http://localhost:8080';

  // util toast
  function showToast(msg, type='danger') {
    const cont = document.getElementById('toastContainer');
    if (!cont) return;
    cont.innerHTML = `
      <div class="alert alert-${type} alert-dismissible fade show nt-shadow-sm" role="alert">
        ${msg}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
      </div>`;
    // shake si error
    if (type === 'danger') {
      const card = document.querySelector('.auth-card');
      if (card) {
        card.classList.remove('shake');
        // fuerza reflow para reiniciar animación
        void card.offsetWidth;
        card.classList.add('shake');
      }
    }
  }

  // eye toggle
  (function(){
    const toggle = document.getElementById('togglePwd');
    const pwd = document.getElementById('password');
    if (toggle && pwd) {
      toggle.addEventListener('click', () => {
        const isPwd = pwd.getAttribute('type') === 'password';
        pwd.setAttribute('type', isPwd ? 'text' : 'password');
        toggle.innerHTML = isPwd ? '<i class="bi bi-eye-slash"></i>' : '<i class="bi bi-eye"></i>';
      });
    }
  })();

  // Enter en password
  (function(){
    const pwd = document.getElementById('password');
    const btn = document.getElementById('goDash');
    if (pwd && btn) {
      pwd.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
          e.preventDefault();
          btn.click();
        }
      });
    }
  })();

  // Prefill remember_user
  (function(){
    const remembered = localStorage.getItem('remember_user');
    if (remembered) {
      const u = document.getElementById('username');
      const cb = document.getElementById('remember');
      if (u) u.value = remembered;
      if (cb) cb.checked = true;
    }
    document.getElementById('year').textContent = new Date().getFullYear();
  })();

  function setLoading(isLoading) {
    const btn = document.getElementById('goDash');
    if (!btn) return;
    const label = btn.querySelector('.btn-label');
    const spinner = btn.querySelector('.btn-spinner');
    if (isLoading) {
      btn.disabled = true;
      label.classList.add('opacity-0');
      spinner.classList.remove('d-none');
    } else {
      btn.disabled = false;
      label.classList.remove('opacity-0');
      spinner.classList.add('d-none');
    }
  }

  // Validación rápida
  function validate() {
    const form = document.getElementById('loginForm');
    const u = document.getElementById('username');
    const p = document.getElementById('password');
    let ok = true;
    if (!u.value.trim()) { u.classList.add('is-invalid'); ok = false; } else { u.classList.remove('is-invalid'); }
    if (!p.value) { p.classList.add('is-invalid'); ok = false; } else { p.classList.remove('is-invalid'); }
    return ok;
  }

  (function(){
    const btn = document.getElementById('goDash');
    if (!btn) return;

    btn.addEventListener('click', async () => {
      if (!validate()) {
        showToast('Por favor completa los campos requeridos.', 'warning');
        return;
      }

      const nombreUsuario = document.getElementById('username').value.trim();
      const password = document.getElementById('password').value;

      const url = new URL('/api/auth/login', API_BASE).toString();
      console.log('[LOGIN] POST', url);

      try {
        setLoading(true);
        const resp = await fetch(url, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ nombreUsuario, password })
        });

        console.log('[LOGIN] status', resp.status, 'from', resp.url);

        let data = null;
        try { data = await resp.json(); } catch {}

        if (!resp.ok) {
          const msg = (data && (data.detail || data.message || data.error)) || `Error ${resp.status}`;
          showToast(msg, 'danger');
          return;
        }

        if (data?.token) {
          localStorage.setItem('auth_token', data.token);
          localStorage.setItem('sessionToken', data.token);
          if (data.expiresAt) localStorage.setItem('auth_expires', data.expiresAt);
          if (data.user) localStorage.setItem('auth_user', JSON.stringify(data.user));

          if (document.getElementById('remember')?.checked) {
            localStorage.setItem('remember_user', nombreUsuario);
          } else {
            localStorage.removeItem('remember_user');
          }

          // pequeña transición de salida
          document.querySelector('.auth-card')?.classList.add('card-success');
          setTimeout(() => {
            window.location.href = '<%= request.getContextPath() %>dashboard.jsp';
          }, 350);
        } else {
          showToast('Login OK pero sin token en la respuesta', 'warning');
        }
      } catch (e) {
        console.error(e);
        showToast('No se pudo conectar con el backend en :8080', 'danger');
      } finally {
        setLoading(false);
      }
    });
  })();

  // Link de olvidé contraseña (dummy)
  document.getElementById('forgotLink')?.addEventListener('click', (e) => {
    e.preventDefault();
    showToast('Contacta al administrador para restablecer tu contraseña.', 'info');
  });
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
