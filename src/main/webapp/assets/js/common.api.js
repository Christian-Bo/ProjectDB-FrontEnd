/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

/* Helpers comunes para llamadas REST y UX consistente.
   - Inyecta encabezado X-User-Id para tus SPs.
   - Maneja JSON y errores.
   - Toast simple para feedback.
*/

const API = {
  baseUrl: '', // relativo al mismo host (Spring y JSP servidos juntos)
  userId: 1     // si luego usas sesión/JWT, reemplaza este seteo
};

// GET con query params
async function apiGet(path, params = {}) {
  const url = new URL(API.baseUrl + path, window.location.origin);
  Object.entries(params).forEach(([k, v]) => {
    if (v !== undefined && v !== null && v !== '') url.searchParams.append(k, v);
  });
  const res = await fetch(url, { headers: { 'Accept': 'application/json' } });
  return handleResponse(res);
}

// POST/PUT JSON con X-User-Id
async function apiSend(method, path, bodyObj) {
  const res = await fetch(API.baseUrl + path, {
    method,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-User-Id': String(API.userId)
    },
    body: JSON.stringify(bodyObj)
  });
  return handleResponse(res);
}

async function apiDelete(path) {
  const res = await fetch(API.baseUrl + path, {
    method: 'DELETE',
    headers: { 'X-User-Id': String(API.userId) }
  });
  return handleResponse(res);
}

async function handleResponse(res) {
  if (res.ok) {
    // En deletes algunos endpoints devuelven número plano; intenta parsear JSON si procede
    const text = await res.text();
    try { return text ? JSON.parse(text) : null; } catch { return text; }
  }
  const errText = await res.text();
  let msg = errText;
  try { const j = JSON.parse(errText); msg = j.message || JSON.stringify(j); } catch { /* noop */ }
  throw new Error(msg || `HTTP ${res.status}`);
}

// Toast Bootstrap
function showToast(message, level = 'primary') {
  const toastEl = document.getElementById('appToast');
  const msgEl = document.getElementById('toastMsg');
  msgEl.textContent = message;
  toastEl.className = `toast align-items-center text-bg-${level} border-0`;
  bootstrap.Toast.getOrCreateInstance(toastEl, { delay: 2800 }).show();
}

// Util: form -> obj (en snake_case; IDs de inputs ya están en snake_case)
function formToObject(formEl) {
  const data = {};
  new FormData(formEl).forEach((v, k) => { data[k] = v; });
  return data;
}

// Util: set values by id (snake_case)
function setValue(id, value) { const el = document.getElementById(id); if (el) el.value = value ?? ''; }
