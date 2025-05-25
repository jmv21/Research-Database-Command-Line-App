.pragma library


function getBrightness(color){
    let colorString = color.toString();

    var r = parseInt(colorString.substr(1, 2), 16);
    var g = parseInt(colorString.substr(3, 2), 16);
    var b = parseInt(colorString.substr(5, 2), 16);
    var brightness = (r * 299 + g * 587 + b * 114) / 1000;

    return brightness
}

function isLightColor(color, tolerance=170){
    let colorString = color.toString();
    let isALightColor = false

    if (colorString.charAt(0) === '#') {
        let brightness = getBrightness(color);

        isALightColor = brightness > tolerance
    } else {
        console.error('color must be an hexadecimal string starting with #');
    }
    return isALightColor;
}

function getTextColor(bgColor, tolerance=170) {
    let colorString = bgColor.toString();

    if (colorString.charAt(0) === '#') {
        let brightness = getBrightness(bgColor);

        return brightness > tolerance ? "black" : "white";
    } else {
        console.error('color must be an hexadecimal string starting with #');
    }
}

function adjustColorForContrast(color, contrastColor, adjustmentFactor = 0.2, tolerance = 170) {
    let colorString = color.toString();
    let contrastColorString = contrastColor.toString();

    if (colorString.charAt(0) === '#' && contrastColorString.charAt(0) === '#') {
        let brightness = getBrightness(contrastColor);
        let isLight = isLightColor(contrastColor, tolerance);

        // Extract RGB values
        var r = parseInt(colorString.substr(1, 2), 16);
        var g = parseInt(colorString.substr(3, 2), 16);
        var b = parseInt(colorString.substr(5, 2), 16);

        // Calculate adjustment amount based on adjustmentFactor
        let adjustmentAmount = Math.floor(255 * adjustmentFactor);

        // Adjust color
        if (isLight) {
            // Darken the color
            r = Math.max(0, r - adjustmentAmount);
            g = Math.max(0, g - adjustmentAmount);
            b = Math.max(0, b - adjustmentAmount);
        } else {
            // Brighten the color
            r = Math.min(255, r + adjustmentAmount);
            g = Math.min(255, g + adjustmentAmount);
            b = Math.min(255, b + adjustmentAmount);
        }

        // Convert back to hexadecimal
        let adjustedColor = "#" + r.toString(16).padStart(2, '0') +
                            g.toString(16).padStart(2, '0') +
                            b.toString(16).padStart(2, '0');

        return adjustedColor;
    } else {
        console.error('Color must be an hexadecimal string starting with #');
        return contrastColor; // Return contrast color if there's an error
    }
}


