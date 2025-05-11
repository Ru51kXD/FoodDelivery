import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

// Глобальные флаги для отслеживания проблем с рендерингом
bool _hasOpenGLError = false;
bool _isEmulator = false;

class SafeImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SafeImage({
    Key? key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Проверяем, что URL не пустой
    if (imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    // Проверяем, что URL корректный
    Uri? uri;
    try {
      uri = Uri.parse(imageUrl);
    } catch (e) {
      return _buildErrorWidget();
    }

    // Проверяем схему URL
    if (!['http', 'https'].contains(uri.scheme)) {
      return _buildErrorWidget();
    }
    
    // Если были ошибки OpenGL, используем упрощенный режим
    if (_hasOpenGLError) {
      return _buildBasicImage(context);
    }

    // Оптимизация - оптимальный размер для кеширования
    // Уменьшаем размеры кеширования на эмуляторе для снижения нагрузки
    final double scale = _isEmulator ? 0.5 : 1.0;
    final int? memCacheWidth = width != null ? 
        (width! * MediaQuery.of(context).devicePixelRatio * scale).ceil() : null;
    final int? memCacheHeight = height != null ? 
        (height! * MediaQuery.of(context).devicePixelRatio * scale).ceil() : null;

    try {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) {
          // Отмечаем ошибку OpenGL если она возникла
          if (error.toString().contains('OpenGL') || 
              error.toString().contains('GL_') || 
              error.toString().contains('EGL')) {
            _hasOpenGLError = true;
            // Переключаемся на упрощенный рендеринг при ошибках OpenGL
            return _buildBasicImage(context);
          }
          return _buildErrorWidget();
        },
        // Оптимизация производительности
        memCacheWidth: memCacheWidth,
        memCacheHeight: memCacheHeight,
        fadeInDuration: _isEmulator ? Duration.zero : const Duration(milliseconds: 150),
        fadeOutDuration: _isEmulator ? Duration.zero : const Duration(milliseconds: 150),
        // Улучшенное кеширование
        cacheKey: imageUrl,
        // Предотвращение повторных загрузок и утечек памяти
        maxWidthDiskCache: _isEmulator ? 400 : 800,
        maxHeightDiskCache: _isEmulator ? 400 : 800,
        filterQuality: _isEmulator ? FilterQuality.low : FilterQuality.medium,
        // Отключаем анимации и плавность на эмуляторе
        placeholderFadeInDuration: _isEmulator ? Duration.zero : const Duration(milliseconds: 200),
        imageBuilder: (context, imageProvider) {
          // На эмуляторе просто показываем изображение без декорации
          if (_isEmulator) {
            return Image(
              image: imageProvider,
              fit: fit,
              width: width,
              height: height,
              filterQuality: FilterQuality.low,
              gaplessPlayback: true,
            );
          }
          
          // На реальном устройстве используем полный рендеринг
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: imageProvider,
                fit: fit,
              ),
            ),
          );
        },
      );
    } catch (e) {
      print("Ошибка отображения изображения: $e");
      _hasOpenGLError = true;
      return _buildBasicImage(context);
    }
  }
  
  // Упрощенный виджет для загрузки изображения при проблемах с OpenGL
  Widget _buildBasicImage(BuildContext context) {
    try {
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        filterQuality: FilterQuality.low,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        gaplessPlayback: true,
        cacheWidth: width?.toInt() ?? 200,
        cacheHeight: height?.toInt() ?? 200,
      );
    } catch (e) {
      print("Ошибка при базовой загрузке изображения: $e");
      return _buildErrorWidget();
    }
  }

  Widget _buildPlaceholder() {
    return placeholder ?? 
      Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
            ),
          ),
        ),
      );
  }

  Widget _buildErrorWidget() {
    return errorWidget ?? 
      Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: Icon(
          Icons.image_not_supported,
          color: Colors.grey[600],
          size: (width ?? 60) / 3,
        ),
      );
  }
}

// Определяем, запущены ли мы на эмуляторе (вызывается из main.dart)
void setEmulatorMode(bool isEmulator) {
  _isEmulator = isEmulator;
} 