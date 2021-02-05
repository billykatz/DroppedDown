void main() {

    // Find the pixel at the coordinate of the actual texture
    vec4 val = texture2D(u_texture, v_tex_coord);
    
    if (val.r > 0.6) {
        gl_FragColor = vec4(u_inputRed,1.0,0.0,1.0);
    } else if (val.r > 0.4) {
        gl_FragColor = vec4(0.5,u_inputGreen,0.5,1.0);
    } else if (val.r > 0.2) {
        gl_FragColor = vec4(0.5,0.2,u_inputBlue,1.0);
    } else {
        gl_FragColor = vec4(0.0,0.5,0.0,u_inputAlpha);
    }
}
