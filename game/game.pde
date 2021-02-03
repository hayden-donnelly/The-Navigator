enum Game_States
{
    MAIN_MENU,
    IN_GAME,
    HOW_TO_PLAY,
    GAME_OVER,
    // Selecting this game state returns the game to the previous game state
    BACK
}

class Game_Manager
{
    Game_States current_game_state;
    Game_States previous_game_state;

    Game_Manager()
    {
        current_game_state = Game_States.MAIN_MENU;
        previous_game_state = Game_States.HOW_TO_PLAY;
    }

    // Sets new game state
    void set_game_state(Game_States gs)
    {
        previous_game_state = current_game_state;
        current_game_state = gs;
    }

    // Returns to the previous game state
    void set_previous_game_state()
    {
        current_game_state = previous_game_state;
    }

    void render_ui(Button[] button_arr)
    {
        rectMode(CENTER);
        textAlign(CENTER, CENTER);
        for(int i = 0; i < button_arr.length; i++)
        {
            button_arr[i].render_button();
        }
    }

    // Checks if any button within a group of buttons has been pressed and sets game state accordingly
    void update_ui(Button[] button_arr)
    {
        for(int i = 0; i < button_arr.length; i++)
        {
            if(button_arr[i].check_click())
            {
                return;
            }
        }
    }
}
Game_Manager game;

class Button
{
    String text; 
    float bg_x, bg_y, bg_w, bg_h, text_x, text_y;
    float bg_x_corner, bg_y_corner;
    PFont text_font;
    color bg_color, text_color;
    // Button changes to this game state when pressed
    Game_States target_game_state;

    Button(String text, float x, float y, float w, float h, String text_font, int text_size, color bg_color, color text_color, Game_States target_game_state)
    {
        this.text = text;
        this.bg_x = x;
        this.bg_y = y;
        this.bg_w = w;
        this.bg_h = h;
        this.text_x = x;
        this.text_y = y;
        this.bg_x_corner = x - (w/2);
        this.bg_y_corner = y - (h/2);
        this.text_font = createFont(text_font, text_size);
        this.bg_color = bg_color;
        this.text_color = text_color;
        this.target_game_state = target_game_state;
    }

    void render_button()
    {
        fill(bg_color);
        rect(bg_x, bg_y, bg_w, bg_h);
        fill(text_color);
        textFont(text_font);
        text(text, text_x, text_y);
    }

    // Checks if this button has been clicked on
    boolean check_click()
    {
        if(mouseX >= bg_x_corner && mouseX <= bg_x_corner+bg_w && mouseY >= bg_y_corner && mouseY <= bg_y_corner+bg_h)
        {
            if(target_game_state != Game_States.BACK)
            {
                game.set_game_state(target_game_state);
            }
            else
            {
                game.set_previous_game_state();
            }
            return true;
        }
        return false;
    }
}
Button[] main_menu_buttons;
Button[] how_to_play_buttons;

class Color_Palette
{
    color c1;
    color c2;
    color c3;
    color c4;
    color c5;
}
Color_Palette pal1;

PFont title_font;

void setup()
{
    size(1280, 720);
    rectMode(CENTER);
    lev1 = new Level();
    
    game = new Game_Manager();
    game.set_game_state(Game_States.MAIN_MENU);

    pal1 = new Color_Palette();
    pal1.c1 = color(34,32,53);
    pal1.c2 = color(87,82,103);
    pal1.c3 = color(141,137,128);
    pal1.c4 = color(101,220,152);
    pal1.c5 = color(160,255,227);

    color ui_bg_color = color(pal1.c1);
    color ui_text_color = color(pal1.c4);

    main_menu_buttons = new Button[2];
    main_menu_buttons[0] = new Button("Play", 640, 200, 300, 50, "Orenasolomayusculas.ttf", 23, ui_bg_color, ui_text_color, Game_States.IN_GAME);
    main_menu_buttons[1] = new Button("How to Play", 640, 300, 300, 50, "Orenasolomayusculas.ttf", 23, ui_bg_color, ui_text_color, Game_States.HOW_TO_PLAY);

    how_to_play_buttons = new Button[1];
    how_to_play_buttons[0] = new Button("Back", 1080, 40, 150, 80, "Orenasolomayusculas.ttf", 23, ui_bg_color, ui_text_color, Game_States.BACK);

    title_font = createFont("Orenasolomayusculas.ttf", 40);






    // Level generation
    int map_width = 50;
    int map_height = 50;
    int max_room_width = 10;
    int min_room_width = 5;
    int max_room_height = 10;
    int min_room_height = 5;
    int area = width * height;
    int number_of_rooms = 20;
    int map[] = new int[area];
    
    for(int i = 0; i < area; i++)
    {
        map[i] = 1;
    }

    int prev_room_center_x = -1;
    int prev_room_center_y = -1;

    for(int i = 0; i < number_of_rooms; i++)
    {
        int room_width = (int)random(min_room_width, max_room_width);
        int room_height = (int)random(min_room_height, max_room_height);
        int room_x = (int)random(1, map_width - room_width-1);
        int room_y = (int)random(1, map_height - room_height-1);

        for(int x = room_x; x < room_x + room_width; x++)
        {
            for(int y = room_y; y < room_y + room_height; y++)
            {
                map[y * map_width + x] = 0;
            }
        }

        int room_center_x = room_x + room_width/2;
        int room_center_y = room_y + room_height/2;

        if(prev_room_center_x != -1)
        {
            int path_dir_x = (int)Math.signum(prev_room_center_x - room_center_x);
            int path_dir_y = (int)Math.signum(prev_room_center_y - room_center_y);

            for(int x = room_center_x; x != prev_room_center_x + path_dir_x; x += path_dir_x)
            {
                map[room_center_y * map_width + x] = 0;
            }

            for(int y = room_center_y; y != prev_room_center_y + path_dir_y; y += path_dir_y)
            {
                map[y * map_width + prev_room_center_x] = 0;
            }
        }

        prev_room_center_x = room_center_x;
        prev_room_center_y = room_center_y;
    }
}

void draw()
{
    switch(game.current_game_state)
    {
        case IN_GAME:
            lev1.p.rotation += rot_dir;
            lev1.p.rotation = (lev1.p.rotation > 360) ? lev1.p.rotation - 360 : lev1.p.rotation;
            lev1.render_level();
            break;
        case MAIN_MENU:
            background(pal1.c1);
            textAlign(CENTER);
            //textSize(50);
            fill(pal1.c4);
            stroke(pal1.c4);
            textFont(title_font);
            text("The Impostor", 640, 100);

            game.render_ui(main_menu_buttons);
            break;
        case HOW_TO_PLAY:
            background(pal1.c1);
            game.render_ui(how_to_play_buttons);
            break;
    }
}

void mousePressed()
{
    switch(game.current_game_state)
    {
        case IN_GAME:
            // shoot gun
            break;
        case MAIN_MENU:
            game.update_ui(main_menu_buttons);
            break;
        case HOW_TO_PLAY:
            game.update_ui(how_to_play_buttons);
            break;
    } 
}