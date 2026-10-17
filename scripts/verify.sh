#!/bin/bash
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CLEAR='\033[0m'

echo -e "${BLUE}=== 🛡️ INICIANDO VERIFICACIÓN DE CALIDAD - TRUEKE ===${CLEAR}\n"

echo -e "${BLUE}[1/3] Ejecutando dart format...${CLEAR}"
dart format --set-exit-if-changed lib test
if [ $? -ne 0 ]; then
    echo -e "\n${RED}❌ ERROR: El código no está formateado correctamente. Ejecuta 'dart format lib test' para solucionarlo.${CLEAR}"
    exit 1
fi
echo -e "${GREEN}✅ Formato correcto.${CLEAR}\n"

echo -e "${BLUE}[2/3] Ejecutando flutter analyze...${CLEAR}"
flutter analyze
if [ $? -ne 0 ]; then
    echo -e "\n${RED}❌ ERROR: Se encontraron lints o errores en el análisis estático.${CLEAR}"
    exit 1
fi
echo -e "${GREEN}✅ Análisis estático limpio (0 issues).${CLEAR}\n"

echo -e "${BLUE}[3/3] Ejecutando flutter test...${CLEAR}"
flutter test
if [ $? -ne 0 ]; then
    echo -e "\n${RED}❌ ERROR: Algunas pruebas han fallado.${CLEAR}"
    exit 1
fi

echo -e "${GREEN}🚀 === ¡TODO PERFECTO! El proyecto está listo para un commit seguro ===${CLEAR}"
exit 0
