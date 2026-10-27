import re

# 1. Corregir formato de precio con decimales (5,00 €) en my_published_products_screen.dart
path_pub = 'lib/features/profile/presentation/screens/my_published_products_screen.dart'
with open(path_pub, 'r') as f:
    code_pub = f.read()

# Reemplazar la línea exacta del price con 0 decimales por 2 decimales y coma
code_pub = code_pub.replace(
    "product.price!.toStringAsFixed(0) + '€'",
    "product.price!.toStringAsFixed(2).replaceFirst('.', ',') + ' €'"
)
code_pub = code_pub.replace(
    "'\${product.price!.toStringAsFixed(0)}€'",
    "'\${product.price!.toStringAsFixed(2).replaceFirst(\".\", \",\")} €'"
)

with open(path_pub, 'w') as f:
    f.write(code_pub)
print("-> my_published_products_screen.dart actualizado con decimales exactos.")

# 2. Corregir ProductInfo (detalle del producto): precio grande, con decimales y coma, y limpiar duplicidades
path_info = 'lib/features/products/widgets/product_info.dart'
with open(path_info, 'r') as f:
    code_info = f.read()

# Asegurar que el precio use dos decimales y coma, y un tamaño imponente (ej: fontSize: 32)
# Vamos a actualizar la sección del precio en ProductInfo
old_price_block_pattern = r"Text\(\s*hasPrice\s*\?\s*\"[^\"]*\"\s*:\s*\"[^\"]*\"\s*,\s*style:\s*TextStyle\([^)]+\)\s*\)"

# Reemplazamos directamente el bloque de texto del precio en ProductInfo para que sea imponente y con decimales exactos
new_price_widget = """Text(
          hasPrice
              ? \"\${product.price!.toStringAsFixed(2).replaceFirst('.', ',')} €\"
              : \"Trueque Directo\",
          style: const TextStyle(
            fontSize: 32,
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
          ),
        )"""

# Limpiar o asegurar que no se muestre información redundante/extra (la tercera palabra "prueba")
# En ProductInfo revisamos las filas de metadatos o etiquetas extra si las hubiera.
