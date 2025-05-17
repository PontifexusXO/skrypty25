#!/bin/bash

# ------------------------------------------
# Gra w kółko i krzyżyk ~ Arkadiusz Adamczyk
# ------------------------------------------

wins=(
    0 1 2
    3 4 5
    6 7 8
    0 3 6
    1 4 7
    2 5 8
    0 4 8
    2 4 6
)
save_file="save_file.txt"

main_menu() {
    echo "Witaj w grze w kółko i krzyżyk:"
    echo "1) Nowa gra dwuosobowa"
    echo "2) Wczytaj grę"
    echo "3) Wyjdź z gry"
    echo ""
    
    read -p "Wybierz opcję (1-3): " -r option
    case "$option" in
        1)
            initialize_game
            game_loop
            ;;
        2)
            if load_game; then
                game_loop
            else
                main_menu
            fi
            ;;
        3)
            exit 0
            ;;
        *)
            echo "Błędna opcja"
            echo ""
            main_menu
            ;;
    esac
}

initialize_game() {
    board=(
        "1" "2" "3"
        "4" "5" "6"
        "7" "8" "9"
    )
    current_player="O"
    is_player_win=false
    is_draw=false
}

game_loop() {
    while true; do
        print_board
        player_move
        
        for ((i = 0; i < ${#wins[@]}; i += 3)); do
            local a=${wins[i]}
            local b=${wins[i+1]}
            local c=${wins[i+2]}
            
            if [[ "${board[a]}" == "${board[b]}" && "${board[b]}" == "${board[c]}" ]]; then
                is_player_win=true
                break
            fi
        done
        if [[ "$is_player_win" == true ]]; then
            print_board
            echo "Gracz $current_player wygrywa!"
            break
        fi
        
        is_draw=true
        for cell in "${board[@]}"; do
            if [[ "$cell" != "X" && "$cell" != "O" ]]; then
                is_draw=false
                break
            fi
        done
        if [[ "$is_draw" == true ]]; then
            print_board
            echo "Remis!"
            break  
        fi
        
        player_switch
    done

    echo "Koniec gry!"
    echo ""
    read -p "Gramy jeszcze raz? (t/n): " -r option
    if [[ "$option" == "t" ]]; then
        echo ""
        main_menu
    else
        exit 0
    fi
}

print_board() {
    echo ""
    echo "###########"
    echo " ${board[0]} | ${board[1]} | ${board[2]} "
    echo "---+---+---"
    echo " ${board[3]} | ${board[4]} | ${board[5]} "
    echo "---+---+---"
    echo " ${board[6]} | ${board[7]} | ${board[8]} "
    echo ""
}

player_move() {
    while true; do
        read -p "Graczu $current_player, podaj pozycję (1-9) lub zapisz stan gry (zapisz): " -r move
        if [[ "$move" == "zapisz" ]]; then
            save_game
            continue
        fi
        if [[ "$move" =~ ^[1-9]$ ]]; then
            local index=$(("$move" - 1))
            if [[ "${board[index]}" != "X" && "${board[index]}" != "O" ]]; then
                board[index]="$current_player"
                break
            else
                echo "Podana pozycja jest już zajęta"
                echo ""
            fi
        else
            echo "Zła pozycja. Podaj liczbę od 1 do 9"
            echo ""
        fi
    done
}

player_switch() {
    if [[ "$current_player" == "O" ]]; then
        current_player="X"
    else
        current_player="O"
    fi
}

save_game() {
    for cell in "${board[@]}"; do
        echo "$cell"
    done > "$save_file"
    echo "$current_player" >> "$save_file"
    echo "Stan gry zapisany do: $save_file"
    echo ""
}

load_game() {
    if [[ ! -f "$save_file" ]]; then
        echo "Brak zapisanych stanów gry"
        echo ""
        return 1
    fi

    mapfile -t saved < "$save_file"
    for i in {0..8}; do
        board[i]="${saved[i]}"
    done
    current_player="${saved[9]}"
    echo "Wczytano stan gry z $save_file"
}

main_menu