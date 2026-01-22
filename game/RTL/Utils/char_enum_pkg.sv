// used to share between modules so they will have the same enum
package char_enum_pkg; 
    typedef enum logic [6:0] {
        // Numbers 0-9
        CHAR_0, CHAR_1, CHAR_2, CHAR_3, CHAR_4, 
        CHAR_5, CHAR_6, CHAR_7, CHAR_8, CHAR_9,
        // Uppercase A-Z
        CHAR_A, CHAR_B, CHAR_C, CHAR_D, CHAR_E, CHAR_F, CHAR_G, CHAR_H, 
        CHAR_I, CHAR_J, CHAR_K, CHAR_L, CHAR_M, CHAR_N, CHAR_O, CHAR_P, 
        CHAR_Q, CHAR_R, CHAR_S, CHAR_T, CHAR_U, CHAR_V, CHAR_W, CHAR_X, 
        CHAR_Y, CHAR_Z,
        // Lowercase a-z
        CHAR_a, CHAR_b, CHAR_c, CHAR_d, CHAR_e, CHAR_f, CHAR_g, CHAR_h, 
        CHAR_i, CHAR_j, CHAR_k, CHAR_l, CHAR_m, CHAR_n, CHAR_o, CHAR_p, 
        CHAR_q, CHAR_r, CHAR_s, CHAR_t, CHAR_u, CHAR_v, CHAR_w, CHAR_x, 
        CHAR_y, CHAR_z,
        // Special Characters
        CHAR_COLON,
        CHAR_NULL = 7'h7F
    } char_name_t;
endpackage