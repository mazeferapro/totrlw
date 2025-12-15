GMap = GMap or {}
GMap.Planets = GMap.Planets or {}
GMap.Vehicles = GMap.Vehicles or {}

GMap.config = {
    colors = {
        white = Color( 255, 255, 255 );
        white_copyright = Color( 255, 255, 255, 10 );

        back = Color( 0, 0, 0 );
        back2 = Color( 7, 110, 203, 5 );
        back3 = Color( 255, 43, 43, 5 );
        back4 = Color( 32, 33, 36, 255 );
        back5 = Color( 30, 30, 30, 100 );

        vignette = Color( 0, 0, 0, 255 );
        blue = Color(49, 118, 209);
        blue_hover = Color(29, 100, 192, 200);

        main_back = Color(0, 0, 0, 150);
        red = Color(253, 1, 1);
        yellow = Color(255, 215, 0);
        gray = Color( 200, 200, 200, 130 );
        gray2 = Color( 200, 200, 200, 30 );
        input_popup = Color(30, 130, 255);
    };

    mats = {
        sector1 = Material('luna_menus/warfare/sector_a.png');
        sector2 = Material('luna_menus/warfare/sector_b.png');
        sector3 = Material('luna_menus/warfare/sector_c.png');
        sector4 = Material('luna_menus/warfare/sector_d.png');
        sector5 = Material('luna_menus/warfare/sector_e.png');
        sector6 = Material('luna_menus/warfare/sector_f.png');
        sector7 = Material('luna_menus/warfare/sector_g.png');
        sector8 = Material('luna_menus/warfare/sector_h.png');
        sector9 = Material('luna_menus/warfare/sector_i.png');

        back1 = Material( 'luna_menus/warfare/galactic-warfare_map.png' );
        back2 = Material('luna_menus/warfare/galactic-warfare_map_blank.png');

        stripes = Material('luna_menus/warfare/stripes_element.png');

        mouse1 = Material( 'luna_ui_base/elements/mouse-var2.png' );
        mouse2 = Material( 'luna_ui_base/elements/mouse-var1.png' );

        planetBack = Material( 'luna_ui_base/etc/plain-circle.png', 'smooth mips' );
        planetElement = Material('luna_menus/progress/circle_species_var2.png', 'smooth mips');

        war1 = Material( 'luna_menus/hud/alert.png', 'smooth mips' );
        war2 = Material( 'luna_icons/annexation.png', 'smooth mips' );

        vignette = Material( 'luna_menus/hud/vignettes/lifemod_vignetteoverlay3.png' );
    };

    planet_color = {
        [1] = Color(49, 118, 209);
        [2] = Color(253, 1, 1);
        [3] = Color(200, 200, 200, 130);
    };
}