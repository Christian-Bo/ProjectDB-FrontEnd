<%-- 
  Document   : index
  Title      : Iniciar sesión • Nextech
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

  <!-- (opcional) hoja externa si ya la tienes; los estilos de abajo son suficientes -->
  <link rel="stylesheet" href="assets/css/login.css">

  <style>
    :root{
      /* helpers derivados de tu base.css */
      --nx-bg: var(--nt-bg);
      --nx-surface: var(--nt-surface);
      --nx-surface-2: var(--nt-surface-2);
      --nx-text: var(--nt-text);
      --nx-title: var(--nt-primary);
      --nx-accent: var(--nt-accent);
      --nx-accent-contrast: var(--nt-accent-contrast);
      --nx-border: var(--nt-border);
      --nx-shadow: var(--nt-shadow);
      --nx-success: var(--nt-success);
    }

    html,body{ height:100%; font-family: 'Poppins', system-ui, -apple-system, Segoe UI, Roboto, 'Helvetica Neue', Arial, 'Noto Sans', 'Apple Color Emoji','Segoe UI Emoji','Segoe UI Symbol'; }
    body.nt-bg{ background: radial-gradient(1200px 800px at 15% -10%, rgba(127,90,240,.15), transparent 60%),
                           radial-gradient(1000px 600px at 110% 10%, rgba(44,182,125,.10), transparent 55%),
                           var(--nx-bg); }

    /* Orbitales suaves del fondo */
    .nt-orbits .nt-orbit{
      position:absolute; border-radius:999px; filter: blur(60px); opacity:.28; pointer-events:none;
      mix-blend-mode:lighten;
    }
    .nt-orbit-1{ width:380px; height:380px; background:var(--nx-accent); top:-80px; left:-80px; }
    .nt-orbit-2{ width:300px; height:300px; background:var(--nx-success); bottom:40px; right:10%; }
    .nt-orbit-3{ width:220px; height:220px; background:#3a86ff; top:30%; left:45%; opacity:.18; }

    .auth-card{
      width: min(1040px, 95vw);
      border:1px solid var(--nx-border);
      border-radius: 1.25rem;
      overflow:hidden;
      background: var(--nx-surface);
      box-shadow: var(--nx-shadow);
      position: relative;
    }

    /* Panel hero (izquierda) */
    .hero{
      min-height:520px;
      background:
        radial-gradient(900px 520px at 30% -10%, rgba(127,90,240,.35), transparent 60%),
        linear-gradient(145deg, rgba(127,90,240,.65), rgba(127,90,240,.35) 55%, rgba(34,34,44,.35));
      color:#fff;
    }
    .brand-badge{
      background: rgba(255,255,255,.12);
      color:#fff; border:1px solid rgba(255,255,255,.2);
      backdrop-filter: blur(4px);
    }
    .env-badge{
      background: rgba(0,0,0,.25);
      color:#e7e7ff; border:1px solid rgba(255,255,255,.15);
      backdrop-filter: blur(4px);
    }
    .hero-copy .nt-caret{ color:#fff; animation: caret 1.1s steps(1,end) infinite; }
    @keyframes caret { 50%{ opacity:0; } }

    .hero-glow{
      position:absolute; inset:auto -20% -20% -20%;
      height:120px; filter: blur(30px);
      background: radial-gradient(60% 100% at 50% 100%, rgba(0,0,0,.35), transparent 65%);
    }

    /* Panel de formulario (derecha) */
    .form-pane{
      background: linear-gradient(180deg, #0f1220 0%, var(--nx-surface) 38%, var(--nx-surface) 100%);
      color: var(--nx-text);
    }
    .nt-title{ color: var(--nx-title); }
    .nt-subtitle{ color: var(--nx-text); opacity:.85; }

    /* Inputs grandes con icono */
    .nt-input .input-group-text{
      background: var(--nx-surface-2);
      border-color: var(--nx-border);
      color: var(--nx-title);
    }
    .nt-input .form-control{
      background:#12141f;
      border-color: var(--nx-border);
      color: var(--nx-title);
    }
    .nt-input .form-control::placeholder{ color:#7f86a1; }
    .nt-input .form-control:focus{
      border-color: var(--nx-accent);
      box-shadow: 0 0 0 .25rem rgba(127,90,240,.25);
      background:#141725;
      color: var(--nx-title);
    }

    /* Botón de ojo */
    .btn-toggle-eye{
      position:absolute; right:.5rem; top:50%; transform:translateY(-50%);
      background: transparent; border:0; color:#cbd0e6;
    }
    .btn-toggle-eye:hover{ color:#fff; }

    /* Botón principal en tu paleta */
    .btn-accent{
      background: var(--nx-accent);
      color: var(--nx-accent-contrast);
      border:1px solid var(--nx-accent);
      box-shadow: 0 10px 26px rgba(127,90,240,.25);
    }
    .btn-accent:hover{ filter: brightness(.96); color:#fff; }
    .btn-accent:disabled{ opacity:.8; }

    /* Toast/alert en el formulario */
    .nt-shadow-sm{ box-shadow: 0 10px 24px rgba(0,0,0,.25); }

    /* Animación de error (shake) */
    .shake{ animation: shake .42s cubic-bezier(.36,.07,.19,.97) both; }
    @keyframes shake{
      10%, 90% { transform: translateX(-1px); }
      20%, 80% { transform: translateX(2px); }
      30%, 50%, 70% { transform: translateX(-4px); }
      40%, 60% { transform: translateX(4px); }
    }

    /* Pequeños detalles */
    .nt-logo{
      display:grid; place-items:center; width:36px; height:36px;
      background: radial-gradient(120% 120% at 30% 10%, rgba(127,90,240,.35), rgba(127,90,240,.15));
      border:1px solid var(--nx-border); border-radius:.75rem; color:#dcd8ff;
    }
  </style>
</head>
<body class="nt-bg">

<main class="min-vh-100 d-flex align-items-center justify-content-center nt-bg overflow-hidden position-relative">
  <!-- Fondo animado -->
  <div class="nt-orbits position-absolute w-100 h-100"></div>

  <div class="auth-card nt-card shadow-xxl">
    <div class="row g-0">
      <!-- HERO -->
      <aside class="col-lg-6 d-none d-lg-flex hero p-4 position-relative">
        <div class="d-flex align-items-start justify-content-between w-100">
          <span class="badge brand-badge">Nextech Store</span>
        </div>
        <div class="hero-copy mt-auto pb-3">
          <h1 class="display-6 fw-bold mb-2 text-white">
            Más allá de los límites<span class="nt-caret">|</span>
          </h1>
          <p class="lead mb-0 text-white-50">
            Tecnología que impulsa tus decisiones.
          </p>
        </div>
        <div class="hero-glow"></div>
      </aside>

      <!-- FORM -->
      <section class="col-12 col-lg-6 form-pane">
        <div class="p-4 p-lg-5 h-100 d-flex flex-column justify-content-center">
          <div class="d-flex align-items-center gap-2 mb-1">
            <div class="nt-logo"><i class="bi bi-kanban"></i></div>
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

            <!-- Recordarme (se mantiene) -->
            <div class="d-flex align-items-center justify-content-between mb-4">
              <div class="form-check">
                <input class="form-check-input" type="checkbox" id="remember" name="remember">
                <label class="form-check-label nt-subtitle" for="remember">Recordarme</label>
              </div>
              <!-- se quitó "¿Olvidaste tu contraseña?" a petición -->
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

<!-- Helpers -->
<script src="assets/js/common.api.js"></script>
<script src="assets/js/auth.guard.js"></script>

<script>
  // Redirige si ya hay sesión activa
  (function autoRedirectIfLogged() {
    try {
      const s = Auth.load?.();
      if (s?.token) { Auth.gotoDashboard(); }
    } catch {}
  })();

  // Fijar base del API al backend en 8080 (override por localStorage.api_base si existe)
  (function configureApiBase(){
    API.baseUrl = localStorage.getItem('api_base') || 'http://localhost:8080';
  })();

  // util toast local (alert dentro del formulario)
  function showToast(msg, type='danger') {
    const cont = document.getElementById('toastContainer');
    if (!cont) return;
    cont.innerHTML = `
      <div class="alert alert-${type} alert-dismissible fade show nt-shadow-sm" role="alert" style="border:1px solid var(--nt-border); background: var(--nt-surface-2); color: var(--nt-primary);">
        ${msg}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
      </div>`;
    if (type === 'danger') {
      const card = document.querySelector('.auth-card');
      if (card) { card.classList.remove('shake'); void card.offsetWidth; card.classList.add('shake'); }
    }
  }

  // Ojo mostrar/ocultar
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

  // Enter envía
  (function(){
    const pwd = document.getElementById('password');
    const btn = document.getElementById('goDash');
    if (pwd && btn) {
      pwd.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') { e.preventDefault(); btn.click(); }
      });
    }
  })();

  // Prefill remember_user y año
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

  function validate() {
    const u = document.getElementById('username');
    const p = document.getElementById('password');
    let ok = true;
    if (!u.value.trim()) { u.classList.add('is-invalid'); ok = false; } else { u.classList.remove('is-invalid'); }
    if (!p.value) { p.classList.add('is-invalid'); ok = false; } else { p.classList.remove('is-invalid'); }
    return ok;
  }

  // CLICK: login
  (function(){
    const btn = document.getElementById('goDash');
    if (!btn) return;

    btn.addEventListener('click', async () => {
      if (!validate()) { showToast('Por favor completa los campos requeridos.', 'warning'); return; }

      const nombreUsuario = document.getElementById('username').value.trim();
      const password = document.getElementById('password').value;

      try {
        setLoading(true);

        // API.post devuelve JSON o lanza Error
        const data = await API.post('/api/auth/login', { nombreUsuario, password });

        if (!data?.token) { showToast('Login OK pero sin token en la respuesta', 'warning'); return; }

        // Guardar sesión y enviar a dashboard según rol
        const session = { token: data.token, expiresAt: data.expiresAt, user: data.user };
        Auth.save(session);

        // Recordarme
        if (document.getElementById('remember')?.checked) {
          localStorage.setItem('remember_user', nombreUsuario);
        } else {
          localStorage.removeItem('remember_user');
        }

        // Transición y redirección
        document.querySelector('.auth-card')?.classList.add('card-success');
        setTimeout(() => Auth.gotoDashboard(), 300);

      } catch (e) {
        console.error(e);
        showToast(e.message || 'No se pudo conectar con el backend', 'danger');
      } finally {
        setLoading(false);
      }
    });
  })();
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
