import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TikBoostLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final double? size;

  const TikBoostLogo({
    super.key,
    this.width,
    this.height,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidth = width ?? size ?? 120;
    final logoHeight = height ?? size ?? 120;
    
    return SvgPicture.string(
      '''<svg width="210" height="209" viewBox="0 0 210 209" fill="none" xmlns="http://www.w3.org/2000/svg">
<rect width="210" height="209" rx="40" fill="white"/>
<path d="M145.145 83.375V88.4938L144.692 112.227V113.623C145.417 115.857 141.671 117.036 139.708 117.346L129.74 108.039L72.1984 167.139C71.111 168.255 68.7248 168.845 67.6676 169H52.7158C49.8161 169 49.3932 164.967 49.5442 162.95L116.147 94.0781L107.992 85.7017C106.18 81.6066 109.351 79.9624 111.164 79.6521C120.376 79.8072 139.345 80.0244 141.52 79.6521C143.695 79.2798 144.843 81.9789 145.145 83.375Z" fill="url(#paint0_linear_27_744)"/>
<path d="M162.362 123.395C161.729 113.965 154.819 111.435 148.892 111.579V88.4938C155.646 88.2008 157.874 86.2141 158.284 77.7907C158.647 70.3451 152.998 68.1734 150.129 68.0183H83.0724L83.4234 123.378L56.018 151.695L55.8874 68.0183H21V41.0278C61.1734 40.2522 144.873 39.1664 158.284 41.0278C175.048 43.3546 184.563 57.3152 185.922 73.1372C187.01 85.7948 176.408 96.0946 170.971 99.6623C186.194 101.524 190 121.534 190 131.306C189.638 158.483 166.591 167.759 155.113 169H75.3908L102.586 142.009C114.215 142.009 142.698 142.382 149.223 142.009C157.378 141.544 163.268 136.891 162.362 123.395Z" fill="url(#paint1_linear_27_744)"/>
<defs>
<linearGradient id="paint0_linear_27_744" x1="21" y1="69.3933" x2="186.016" y2="147.974" gradientUnits="userSpaceOnUse">
<stop stop-color="#3E5EF0"/>
<stop offset="1" stop-color="#F05A5A"/>
</linearGradient>
<linearGradient id="paint1_linear_27_744" x1="21" y1="69.3933" x2="186.016" y2="147.974" gradientUnits="userSpaceOnUse">
<stop stop-color="#3E5EF0"/>
<stop offset="1" stop-color="#F05A5A"/>
</linearGradient>
</defs>
</svg>''',
      width: logoWidth,
      height: logoHeight,
    );
  }
}

class TikBoostLogoIcon extends StatelessWidget {
  final double? width;
  final double? height;
  final double? size;

  const TikBoostLogoIcon({
    super.key,
    this.width,
    this.height,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final logoWidth = width ?? size ?? 24;
    final logoHeight = height ?? size ?? 24;
    
    return SvgPicture.string(
      '''<svg width="210" height="209" viewBox="0 0 210 209" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M145.145 83.375V88.4938L144.692 112.227V113.623C145.417 115.857 141.671 117.036 139.708 117.346L129.74 108.039L72.1984 167.139C71.111 168.255 68.7248 168.845 67.6676 169H52.7158C49.8161 169 49.3932 164.967 49.5442 162.95L116.147 94.0781L107.992 85.7017C106.18 81.6066 109.351 79.9624 111.164 79.6521C120.376 79.8072 139.345 80.0244 141.52 79.6521C143.695 79.2798 144.843 81.9789 145.145 83.375Z" fill="url(#paint0_linear_27_744)"/>
<path d="M162.362 123.395C161.729 113.965 154.819 111.435 148.892 111.579V88.4938C155.646 88.2008 157.874 86.2141 158.284 77.7907C158.647 70.3451 152.998 68.1734 150.129 68.0183H83.0724L83.4234 123.378L56.018 151.695L55.8874 68.0183H21V41.0278C61.1734 40.2522 144.873 39.1664 158.284 41.0278C175.048 43.3546 184.563 57.3152 185.922 73.1372C187.01 85.7948 176.408 96.0946 170.971 99.6623C186.194 101.524 190 121.534 190 131.306C189.638 158.483 166.591 167.759 155.113 169H75.3908L102.586 142.009C114.215 142.009 142.698 142.382 149.223 142.009C157.378 141.544 163.268 136.891 162.362 123.395Z" fill="url(#paint1_linear_27_744)"/>
<defs>
<linearGradient id="paint0_linear_27_744" x1="21" y1="69.3933" x2="186.016" y2="147.974" gradientUnits="userSpaceOnUse">
<stop stop-color="#3E5EF0"/>
<stop offset="1" stop-color="#F05A5A"/>
</linearGradient>
<linearGradient id="paint1_linear_27_744" x1="21" y1="69.3933" x2="186.016" y2="147.974" gradientUnits="userSpaceOnUse">
<stop stop-color="#3E5EF0"/>
<stop offset="1" stop-color="#F05A5A"/>
</linearGradient>
</defs>
</svg>''',
      width: logoWidth,
      height: logoHeight,
    );
  }
}
