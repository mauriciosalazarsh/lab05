from flask import Flask, render_template, request, redirect, url_for, flash
import mysql.connector
import os
import time

app = Flask(__name__)
app.secret_key = 'tu_clave_secreta_aqui'

def get_db_connection():
    max_retries = 5
    retry_count = 0
    while retry_count < max_retries:
        try:
            connection = mysql.connector.connect(
                host=os.getenv('DB_HOST', 'mysql'),
                user=os.getenv('DB_USER', 'root'),
                password=os.getenv('DB_PASSWORD', 'root123'),
                database=os.getenv('DB_NAME', 'universidad'),
                charset='utf8mb4',
                collation='utf8mb4_unicode_ci',
                use_unicode=True
            )
            return connection
        except mysql.connector.Error as err:
            retry_count += 1
            if retry_count == max_retries:
                raise err
            time.sleep(2)

@app.route('/')
def index():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute('SELECT * FROM profesor ORDER BY profesor_id')
    profesores = cursor.fetchall()
    cursor.close()
    conn.close()
    return render_template('index.html', profesores=profesores)

@app.route('/crear', methods=['GET', 'POST'])
def crear():
    if request.method == 'POST':
        nombre = request.form['nombre']
        apellido = request.form['apellido']
        dni = request.form['dni']
        email = request.form['email']
        telefono = request.form.get('telefono', '')
        especialidad = request.form['especialidad']
        titulo_academico = request.form.get('titulo_academico', '')

        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO profesor (nombre, apellido, dni, email, telefono, especialidad, titulo_academico) VALUES (%s, %s, %s, %s, %s, %s, %s)',
            (nombre, apellido, dni, email, telefono, especialidad, titulo_academico)
        )
        conn.commit()
        cursor.close()
        conn.close()

        flash('Profesor creado exitosamente', 'success')
        return redirect(url_for('index'))

    return render_template('crear.html')

@app.route('/editar/<int:id>', methods=['GET', 'POST'])
def editar(id):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    if request.method == 'POST':
        nombre = request.form['nombre']
        apellido = request.form['apellido']
        dni = request.form['dni']
        email = request.form['email']
        telefono = request.form.get('telefono', '')
        especialidad = request.form['especialidad']
        titulo_academico = request.form.get('titulo_academico', '')

        cursor.execute(
            'UPDATE profesor SET nombre=%s, apellido=%s, dni=%s, email=%s, telefono=%s, especialidad=%s, titulo_academico=%s WHERE profesor_id=%s',
            (nombre, apellido, dni, email, telefono, especialidad, titulo_academico, id)
        )
        conn.commit()
        cursor.close()
        conn.close()

        flash('Profesor actualizado exitosamente', 'success')
        return redirect(url_for('index'))

    cursor.execute('SELECT * FROM profesor WHERE profesor_id = %s', (id,))
    profesor = cursor.fetchone()
    cursor.close()
    conn.close()

    return render_template('editar.html', profesor=profesor)

@app.route('/eliminar/<int:id>')
def eliminar(id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('DELETE FROM profesor WHERE profesor_id = %s', (id,))
    conn.commit()
    cursor.close()
    conn.close()

    flash('Profesor eliminado exitosamente', 'success')
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
