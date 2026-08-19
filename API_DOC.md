# Documentación de la API Provisional de Asistencias

API REST provisional (Express + PostgreSQL) para la app móvil de profesores.
Replica los endpoints documentados en `appAsistencia.md` mientras se recupera la API original.

## Datos generales

| Dato | Valor |
|------|-------|
| URL base local | `http://localhost:4000` |
| URL base Render | `https://<tu-servicio>.onrender.com` |
| Credenciales de prueba | `usuario: rcuadras` / `contraseña: rcuadras` |
| Formato | JSON (`Content-Type: application/json`) |

## Autenticación (COOKIES — obligatorio)

La API usa sesiones basadas en cookies. Al hacer login el servidor devuelve la cookie
`connect.sid`, que **debe enviarse en todas las peticiones siguientes**.

- Sin la cookie, las rutas protegidas responden `401`.
- La sesión expira después de 8 horas.
- La app Kotlin debe implementar un `CookieJar` (OkHttp) para guardar/enviar la cookie automáticamente.

---

## 1. Login

`POST /api/login`

Autentica al maestro. No requiere cookie previa.

**Request body:**
```json
{
  "usuario": "rcuadras",
  "contrasena": "rcuadras"
}
```

**Response 200:**
```json
{
  "success": true,
  "user": {
    "id": 26,
    "nombre": "RAMÓN PATRICIO VELÁZQUEZ CUADRAS",
    "usuario": "rcuadras",
    "tipoUsuario": "maestro"
  }
}
```

**Response 401:**
```json
{
  "success": false,
  "message": "Credenciales incorrectas"
}
```

> Guarda el `id` del usuario y verifica que `tipoUsuario` sea `"maestro"`.

---

## 2. Verificar sesión

`GET /api/session`

Verifica si la sesión sigue activa (útil al abrir la app).

**Response 200:**
```json
{
  "success": true,
  "user": {
    "id": 26,
    "nombre": "RAMÓN PATRICIO VELÁZQUEZ CUADRAS",
    "usuario": "rcuadras",
    "tipoUsuario": "maestro"
  }
}
```

**Response 401:**
```json
{
  "success": false,
  "message": "No hay sesión activa"
}
```

---

## 3. Logout

`POST /api/logout`

Cierra la sesión del maestro.

**Response 200:**
```json
{
  "success": true,
  "message": "Sesión cerrada correctamente"
}
```

---

## 4. Obtener asignaciones del día

`GET /api/asignaciones?id_maestro={id}`

**Requiere cookie de sesión.**

Obtiene todas las clases del maestro. La app filtra localmente por `dia_semana`
y ordena por `hora_inicio`.

**Query parameters:**
- `id_maestro` (requerido): ID del maestro obtenido en el login.

**Response 200:**
```json
[
  {
    "id_asignacion": 87,
    "id_maestro": 26,
    "nombre_maestro": "RAMÓN PATRICIO VELÁZQUEZ CUADRAS",
    "id_materia": 95,
    "nombre_materia": "Programación con sistemas gestores de base de datos",
    "codigo_materia": "PSGB20",
    "id_grupo": 8,
    "nombre_grupo": "507 INFO23",
    "id_semestre": 15,
    "numero_semestre": 5,
    "nombre_semestre": "Quinto Semestre",
    "id_carrera": 2,
    "nombre_carrera": "INFORMATICA",
    "dia_semana": "Jueves",
    "hora_inicio": "07:00:00",
    "hora_fin": "07:50:00"
  }
]
```

> Días en español: `"Lunes"`, `"Martes"`, `"Miércoles"`, `"Jueves"`, `"Viernes"`.

**Sin cookie — Response 401:**
```json
{
  "success": false,
  "message": "No hay sesión activa"
}
```

---

## 5. Lista de alumnos

`GET /api/asistencias/lista-alumnos?id_asignacion={id}`

**Requiere cookie de sesión.**

Obtiene la lista de alumnos del grupo de una clase para pasar asistencia.
Los alumnos vienen ordenados alfabéticamente por apellidos.

**Query parameters:**
- `id_asignacion` (requerido): ID de la asignación seleccionada.

**Response 200:**
```json
{
  "asignacion": {
    "id_asignacion": 87,
    "nombre_materia": "Programación con sistemas gestores de base de datos",
    "nombre_grupo": "507 INFO23",
    "dia_semana": "Jueves",
    "hora_inicio": "07:00:00"
  },
  "alumnos": [
    {
      "id_alumno": 1,
      "matricula": "20260001",
      "nombre_completo": "García López Juan Carlos",
      "foto_base64": "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
    },
    {
      "id_alumno": 2,
      "matricula": "20260002",
      "nombre_completo": "Hernández Pérez María",
      "foto_base64": null
    }
  ]
}
```

> `foto_base64` puede ser `null` si el alumno no tiene foto.
> `nombre_completo` tiene formato: "ApellidoPaterno ApellidoMaterno Nombre".

**Response 404:** `{"success": false, "message": "Asignación no encontrada"}`

---

## 6. Registrar asistencias

`POST /api/asistencias/registrar`

**Requiere cookie de sesión.**

Registra las asistencias de todos los alumnos de una clase. Se recomienda enviar
todos los alumnos en una sola petición.

**Request body:**
```json
{
  "id_asignacion": 87,
  "fecha": "2026-01-14",
  "asistencias": [
    {
      "id_alumno": 1,
      "estado": "asistencia",
      "observaciones": null
    },
    {
      "id_alumno": 2,
      "estado": "falta",
      "observaciones": "No se presentó"
    },
    {
      "id_alumno": 3,
      "estado": "asistencia",
      "observaciones": null
    },
    {
      "id_alumno": 4,
      "estado": "justificante",
      "observaciones": "Cita médica"
    }
  ]
}
```

**Estados disponibles:**

| Estado | Descripción |
|--------|-------------|
| `asistencia` | El alumno está presente |
| `falta` | El alumno no asistió |
| `justificante` | Falta justificada |

**Response 201 (primer registro):**
```json
{
  "success": true,
  "message": "Asistencias registradas exitosamente",
  "data": {
    "registradas": 4,
    "fecha": "2026-01-14",
    "actualizadas": false
  }
}
```

**Response 201 (ya existían registros, se actualizan):**
```json
{
  "success": true,
  "message": "Asistencias registradas exitosamente",
  "data": {
    "registradas": 4,
    "fecha": "2026-01-14",
    "actualizadas": true
  }
}
```

> `fecha` en formato `YYYY-MM-DD`. `observaciones` es opcional (puede ser `null`).
> Si ya existen registros para la misma asignación/fecha, se actualizan (upsert).

---

## 7. Health check

`GET /api/health`

Verifica que la API esté activa (sin autenticación).

**Response 200:**
```json
{
  "success": true,
  "message": "API de asistencias activa"
}
```

---

## Resumen de endpoints

| Acción | Método | Endpoint | Requiere cookie |
|--------|--------|----------|:---:|
| Login | POST | `/api/login` | No |
| Verificar sesión | GET | `/api/session` | No |
| Logout | POST | `/api/logout` | No |
| Health check | GET | `/api/health` | No |
| Obtener asignaciones | GET | `/api/asignaciones?id_maestro={id}` | Sí |
| Lista de alumnos | GET | `/api/asistencias/lista-alumnos?id_asignacion={id}` | Sí |
| Registrar asistencia | POST | `/api/asistencias/registrar` | Sí |

## Notas de seguridad

1. **Cookies**: todas las peticiones después del login deben incluir `connect.sid`.
   En Kotlin, configurar OkHttp con `CookieJar`.
2. **Sesión expirada**: al abrir la app verificar con `GET /api/session` y manejar el `401`
   (redirigir al login).