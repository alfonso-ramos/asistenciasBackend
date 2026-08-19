## ? API para Aplicaci�n M�vil de Profesores (Kotlin)

Esta secci�n documenta las APIs espec�ficas necesarias para desarrollar una aplicaci�n m�vil en Kotlin que permita a los maestros pasar lista desde sus dispositivos.

### ? Flujo de la Aplicaci�n
```
???????????????????     ???????????????????????     ????????????????????     ???????????????????
?   1. LOGIN      ??????? 2. CARGAR CLASES    ??????? 3. SELECCIONAR   ??????? 4. PASAR LISTA  ?
?   del Maestro   ?     ?    DEL D�A          ?     ?    CLASE         ?     ?    y GUARDAR    ?
???????????????????     ???????????????????????     ????????????????????     ???????????????????
```

---

### ? Paso 1: Autenticaci�n

#### Requisitos para Iniciar Sesi�n

**?? Importante sobre las credenciales:**
- Las credenciales son asignadas por el **administrador del sistema** desde el panel de administraci�n web
- El maestro debe estar registrado con `tipo_usuario = 'maestro'` y `activo = true`
- Si el maestro no tiene cuenta, debe solicitarla al administrador
- las credeciales para profesor para realizar pruebas es : 
  user: rcuadras : Pass : rcuadras 
- url base : https://projectoasistencia.onrender.com/

#### ? Manejo de Cookies (OBLIGATORIO)

La API utiliza **sesiones basadas en cookies** para mantener al usuario autenticado.

**�C�mo funciona?**
1. Al hacer login exitoso, el servidor devuelve una cookie llamada `connect.sid`
2. Esta cookie **debe enviarse en TODAS las peticiones siguientes**
3. Si no se env�a la cookie, el servidor responder� con error `401 Unauthorized`

| Cookie | Descripci�n |
|--------|-------------|
| `connect.sid` | Identificador �nico de sesi�n (obligatorio para todas las peticiones despu�s del login) |

**Configuraci�n en Kotlin (OkHttp):**
```kotlin
// Implementar CookieJar para guardar y enviar cookies autom�ticamente
private val cookieJar = object : CookieJar {
    private val cookieStore = mutableMapOf<String, List<Cookie>>()
    
    override fun saveFromResponse(url: HttpUrl, cookies: List<Cookie>) {
        cookieStore[url.host] = cookies
    }
    
    override fun loadForRequest(url: HttpUrl): List<Cookie> {
        return cookieStore[url.host] ?: emptyList()
    }
}

val okHttpClient = OkHttpClient.Builder()
    .cookieJar(cookieJar)  // ? OBLIGATORIO para mantener la sesi�n
    .build()
```

**?? Sin el manejo de cookies:**
- El login funcionar� correctamente
- Pero las siguientes peticiones (`/api/asignaciones`, `/api/asistencias/*`) fallar�n con error 401

---

#### POST `/api/login`
**Descripci�n:** Iniciar sesi�n del maestro

**Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "usuario": "rcuadras",
  "contrasena": "rcuadras"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "user": {
    "id": 26,
    "nombre": "RAM�N PATRICIO VEL�ZQUEZ CUADRAS",
    "usuario": "rcuadras",
    "tipoUsuario": "maestro"
  }
}
```

**Response Error (401):**
```json
{
  "success": false,
  "message": "Credenciales incorrectas"
}
```

**? Notas para Kotlin:**
- Guardar el `id` del usuario en ADO/usuarios
- El `tipoUsuario` debe ser `"maestro"` para acceder al portal de profesores
- Implementar manejo de cookies para mantener la sesi�n

### ? Paso 2: Obtener Asignaciones del D�a

#### GET `/api/asignaciones?id_maestro={id}`
**Descripci�n:** Obtener todas las asignaciones del maestro

**Headers:**
```
Content-Type: application/json
Cookie: connect.sid=<session_cookie>
```

**Query Parameters:**
- `id_maestro` (requerido): ID del maestro obtenido en el login

**Response (200):**
```json
[
  {
    "id_asignacion": 87,
    "id_maestro": 26,
    "nombre_maestro": "RAM�N PATRICIO VEL�ZQUEZ CUADRAS  ",
    "id_materia": 95,
    "nombre_materia": "Programaci�n con sistemas gestores de base de datos",
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
  },
  {
    "id_asignacion": 88,
    "id_maestro": 26,
    "nombre_maestro": "RAM�N PATRICIO VEL�ZQUEZ CUADRAS  ",
    "id_materia": 95,
    "nombre_materia": "Programaci�n con sistemas gestores de base de datos",
    "codigo_materia": "PSGB20",
    "id_grupo": 8,
    "nombre_grupo": "507 INFO23",
    "id_semestre": 15,
    "numero_semestre": 5,
    "nombre_semestre": "Quinto Semestre",
    "id_carrera": 2,
    "nombre_carrera": "INFORMATICA",
    "dia_semana": "Jueves",
    "hora_inicio": "07:50:00",
    "hora_fin": "08:40:00"
  },
  {
    "id_asignacion": 109,
    "id_maestro": 26,
    "nombre_maestro": "RAM�N PATRICIO VEL�ZQUEZ CUADRAS  ",
    "id_materia": 95,
    "nombre_materia": "Programaci�n con sistemas gestores de base de datos",
    "codigo_materia": "PSGB20",
    "id_grupo": 9,
    "nombre_grupo": "508 INFO23",
    "id_semestre": 15,
    "numero_semestre": 5,
    "nombre_semestre": "Quinto Semestre",
    "id_carrera": 2,
    "nombre_carrera": "INFORMATICA",
    "dia_semana": "Martes",
    "hora_inicio": "07:50:00",
    "hora_fin": "08:40:00"
  },
  {
    "id_asignacion": 130,
    "id_maestro": 26,
    "nombre_maestro": "RAM�N PATRICIO VEL�ZQUEZ CUADRAS  ",
    "id_materia": 95,
    "nombre_materia": "Programaci�n con sistemas gestores de base de datos",
    "codigo_materia": "PSGB20",
    "id_grupo": 9,
    "nombre_grupo": "508 INFO23",
    "id_semestre": 15,
    "numero_semestre": 5,
    "nombre_semestre": "Quinto Semestre",
    "id_carrera": 2,
    "nombre_carrera": "INFORMATICA",
    "dia_semana": "Viernes",
    "hora_inicio": "07:50:00",
    "hora_fin": "08:40:00"
  },
  {
    "id_asignacion": 124,
    "id_maestro": 26,
    "nombre_maestro": "RAM�N PATRICIO VEL�ZQUEZ CUADRAS  ",
    "id_materia": 95,
    "nombre_materia": "Programaci�n con sistemas gestores de base de datos",
    "codigo_materia": "PSGB20",
    "id_grupo": 9,
    "nombre_grupo": "508 INFO23",
    "id_semestre": 15,
    "numero_semestre": 5,
    "nombre_semestre": "Quinto Semestre",
    "id_carrera": 2,
    "nombre_carrera": "INFORMATICA",
    "dia_semana": "Jueves",
    "hora_inicio": "08:40:00",
    "hora_fin": "09:30:00"
  },
  {
    "id_asignacion": 131,
    "id_maestro": 26,
    "nombre_maestro": "RAM�N PATRICIO VEL�ZQUEZ CUADRAS  ",
    "id_materia": 95,
    "nombre_materia": "Programaci�n con sistemas gestores de base de datos",
    "codigo_materia": "PSGB20",
    "id_grupo": 9,
    "nombre_grupo": "508 INFO23",
    "id_semestre": 15,
    "numero_semestre": 5,
    "nombre_semestre": "Quinto Semestre",
    "id_carrera": 2,
    "nombre_carrera": "INFORMATICA",
    "dia_semana": "Viernes",
    "hora_inicio": "08:40:00",
    "hora_fin": "09:30:00"
  },
  {
    "id_asignacion": 83,
    "id_maestro": 26,
    "nombre_maestro": "RAM�N PATRICIO VEL�ZQUEZ CUADRAS  ",
    "id_materia": 95,
    "nombre_materia": "Programaci�n con sistemas gestores de base de datos",
    "codigo_materia": "PSGB20",
    "id_grupo": 8,
    "nombre_grupo": "507 INFO23",
    "id_semestre": 15,
    "numero_semestre": 5,
    "nombre_semestre": "Quinto Semestre",
    "id_carrera": 2,
    "nombre_carrera": "INFORMATICA",
    "dia_semana": "Mi�rcoles",
    "hora_inicio": "10:00:00",
    "hora_fin": "10:50:00"
  },
  {
    "id_asignacion": 94,
    "id_maestro": 26,
    "nombre_maestro": "RAM�N PATRICIO VEL�ZQUEZ CUADRAS  ",
    "id_materia": 95,
    "nombre_materia": "Programaci�n con sistemas gestores de base de datos",
    "codigo_materia": "PSGB20",
    "id_grupo": 8,
    "nombre_grupo": "507 INFO23",
    "id_semestre": 15,
    "numero_semestre": 5,
    "nombre_semestre": "Quinto Semestre",
    "id_carrera": 2,
    "nombre_carrera": "INFORMATICA",
    "dia_semana": "Viernes",
    "hora_inicio": "07:00:00",
    "hora_fin": "07:50:00"
  },
  {
    "id_asignacion": 75,
    "id_maestro": 26,
    "nombre_maestro": "RAM�N PATRICIO VEL�ZQUEZ CUADRAS  ",
    "id_materia": 95,
    "nombre_materia": "Programaci�n con sistemas gestores de base de datos",
    "codigo_materia": "PSGB20",
    "id_grupo": 8,
    "nombre_grupo": "507 INFO23",
    "id_semestre": 15,
    "numero_semestre": 5,
    "nombre_semestre": "Quinto Semestre",
    "id_carrera": 2,
    "nombre_carrera": "INFORMATICA",
    "dia_semana": "Martes",
    "hora_inicio": "08:40:00",
    "hora_fin": "09:30:00"
  },
  {
    "id_asignacion": 108,
    "id_maestro": 26,
    "nombre_maestro": "RAM�N PATRICIO VEL�ZQUEZ CUADRAS  ",
    "id_materia": 95,
    "nombre_materia": "Programaci�n con sistemas gestores de base de datos",
    "codigo_materia": "PSGB20",
    "id_grupo": 9,
    "nombre_grupo": "508 INFO23",
    "id_semestre": 15,
    "numero_semestre": 5,
    "nombre_semestre": "Quinto Semestre",
    "id_carrera": 2,
    "nombre_carrera": "INFORMATICA",
    "dia_semana": "Martes",
    "hora_inicio": "07:00:00",
    "hora_fin": "07:50:00"
  }
]
```

**? Notas para Kotlin:**
- Filtrar localmente las asignaciones por el d�a actual usando `dia_semana`
- Los d�as de la semana vienen en espa�ol: "Lunes", "Martes", "Mi�rcoles", "Jueves", "Viernes"
- Ordenar por `hora_inicio` para mostrar en orden cronol�gico


### ? Paso 3: Obtener Lista de Alumnos

#### GET `/api/asistencias/lista-alumnos?id_asignacion={id}`
**Descripci�n:** Obtener la lista de alumnos de un grupo para pasar asistencia

**Headers:**
```
Content-Type: application/json
Cookie: connect.sid=<session_cookie>
```

**Query Parameters:**
- `id_asignacion` (requerido): ID de la asignaci�n seleccionada

**Response (200):**
```json
{
  "asignacion": {
    "id_asignacion": 1,
    "nombre_materia": "Programaci�n I",
    "nombre_grupo": "A",
    "dia_semana": "Lunes",
    "hora_inicio": "07:00:00"
  },
  "alumnos": [
    {
      "id_alumno": 1,
      "matricula": "20260001",
      "nombre_completo": "Garc�a L�pez Juan Carlos",
      "foto_base64": "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
    },
    {
      "id_alumno": 2,
      "matricula": "20260002",
      "nombre_completo": "Hern�ndez P�rez Mar�a",
      "foto_base64": null
    },
    {
      "id_alumno": 3,
      "matricula": "20260003",
      "nombre_completo": "Mart�nez Rodr�guez Pedro",
      "foto_base64": "data:image/jpeg;base64,/9j/4AAQSkZJRg..."
    }
  ]
}
```

**? Notas para Kotlin:**
- `foto_base64` puede ser `null` si el alumno no tiene foto
- Los alumnos vienen ordenados alfab�ticamente por apellidos
- El `nombre_completo` tiene formato: "ApellidoPaterno ApellidoMaterno Nombre"

### ? Paso 4: Registrar Asistencias

#### POST `/api/asistencias/registrar`
**Descripci�n:** Registrar las asistencias de todos los alumnos de una clase

**Headers:**
```
Content-Type: application/json
Cookie: connect.sid=<session_cookie>
```

**Request Body:**
```json
{
  "id_asignacion": 1,
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
      "observaciones": "No se present�"
    },
    {
      "id_alumno": 3,
      "estado": "asistencia",
      "observaciones": null
    },
    {
      "id_alumno": 4,
      "estado": "justificante",
      "observaciones": "Cita m�dica"
    }
  ]
}
```

**Estados disponibles:**
| Estado | Descripci�n |
|--------|-------------|
| `asistencia` | El alumno est� presente |
| `falta` | El alumno no asisti� |
| `justificante` | Falta justificada |

Por default se muestra este item en la lista de alumnos

Aparece por default:

![reg_Asistecia.png](app/src/main/res/drawable/reg_Asistecia.png)

Dar clic aparece : No Asistio
![reg_falta.png](app/src/main/res/drawable/reg_falta.png)

al clic cambiara

![reg_Justificada.png](app/src/main/res/drawable/reg_Justificada.png)



**Response Success (201):**
```json
{
  "success": true,
  "message": "Asistencias registradas exitosamente",
  "data": {
    "registradas": 30,
    "fecha": "2026-01-14",
    "actualizadas": false
  }
}
```

**Response (Si ya exist�an registros - se actualizan):**
```json
{
  "success": true,
  "message": "Asistencias registradas exitosamente",
  "data": {
    "registradas": 30,
    "fecha": "2026-01-14",
    "actualizadas": true
  }
}
```

**? Notas para Kotlin:**
- La fecha debe estar en formato `YYYY-MM-DD`
- `observaciones` es opcional (puede ser `null`)
- Si ya existen registros para la misma asignaci�n/fecha, se actualizan autom�ticamente
- Se recomienda enviar todos los alumnos en una sola petici�n


### ? Endpoints Adicionales �tiles

#### GET `/api/session`
**Descripci�n:** Verificar si la sesi�n sigue activa (�til al abrir la app)

**Response Success (200):**
```json
{
  "success": true,
  "user": {
    "id": 1,
    "nombre": "Juan P�rez Garc�a",
    "usuario": "jperez",
    "tipoUsuario": "maestro"
  }
}
```

**Response Error (401):**
```json
{
  "success": false,
  "message": "No hay sesi�n activa"
}
```

---

#### POST `/api/logout`
**Descripci�n:** Cerrar sesi�n del maestro

**Response (200):**
```json
{
  "success": true,
  "message": "Sesi�n cerrada correctamente"
}
```

### ? Resumen de Endpoints para la App M�vil

| Acci�n | M�todo | Endpoint | Descripci�n |
|--------|--------|----------|-------------|
| Login | POST | `/api/login` | Autenticar maestro |
| Verificar Sesi�n | GET | `/api/session` | Validar si hay sesi�n activa |
| Logout | POST | `/api/logout` | Cerrar sesi�n |
| Obtener Asignaciones | GET | `/api/asignaciones?id_maestro={id}` | Lista de clases del maestro |
| Lista de Alumnos | GET | `/api/asistencias/lista-alumnos?id_asignacion={id}` | Alumnos para pasar lista |
| Registrar Asistencia | POST | `/api/asistencias/registrar` | Guardar el pase de lista |


### ? Consideraciones de Seguridad

1. **Manejo de Cookies**: Express usa cookies de sesi�n (`connect.sid`). Configurar OkHttp con CookieJar.

2. **Timeout de Sesi�n**: Verificar la sesi�n al iniciar la app y manejar el error 401.
