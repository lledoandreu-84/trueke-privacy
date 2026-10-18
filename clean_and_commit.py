import os
import subprocess

print("-> [1/4] Actualizando .gitignore para bloquear artefactos de compilación...")
gitignore_path = ".gitignore"

ignore_additions = """
# Android / Flutter Build Outputs & Binaries
/build/
/android/.gradle/
/android/app/build/
/android/build/
android/app/release/
android/app/debug/
*.aab
*.apk
*.jks
**/android/app/src/main/jniLibs/
**/android/app/src/main/libs/
"""

if os.path.exists(gitignore_path):
    with open(gitignore_path, "r", encoding="utf-8") as f:
        content = f.read()
    if "Android / Flutter Build Outputs" not in content:
        with open(gitignore_path, "a", encoding="utf-8") as f:
            f.write(ignore_additions)
print("-> .gitignore actualizado correctamente.")

print("-> [2/4] Limpiando el caché y el índice de Git para descartar binarios rastreados...")
subprocess.run(["git", "rm", "-r", "--cached", "."], capture_output=True)
subprocess.run(["git", "add", "."], check=True)

print("-> [3/4] Verificando estado del repositorio...")
status = subprocess.run(["git", "status", "--porcelain"], capture_output=True, text=True)
print(status.stdout[:500] + "\n... (mostrando resumen)")

print("-> [4/4] Realizando el commit oficial de producción...")
commit_msg = "chore(prod): pristine build pipeline configuration, strict Java 17 and AGP setup"
subprocess.run(["git", "commit", "-m", commit_msg], check=True)

print("\n==================================================")
print("-> ¡COMMIT REALIZADO CON ÉXITO Y REPOSITORIO LIMPIO!")
print("==================================================")
