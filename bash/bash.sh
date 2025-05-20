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
player_1="O"
player_2="X"

main_menu() {
    echo "Witaj w grze w kółko i krzyżyk:"
    echo "1) Nowa gra dwuosobowa"
    echo "2) Nowa gra z komputerem"
    echo "3) Wczytaj grę"
    echo "4) Wyjdź z gry"
    echo ""
    
    read -p "Wybierz opcję (1-4): " -r option
    case "$option" in
        1)
            initialize_game
            game_loop
            ;;
        2)
            initialize_game
            is_ai_game=true
            game_loop
            ;;
        3)
            if load_game; then
                game_loop
            else
                main_menu
            fi
            ;;
        4)
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
    current_player="$player_1"
    is_player_win=false
    is_draw=false
    is_ai_game=false
}

game_loop() {
    while true; do
        print_board
        if [[ "$is_ai_game" == true && "$current_player" == "$player_2" ]]; then
            ai_move
        else
            player_move
        fi
        
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
            if [[ "$cell" != "$player_2" && "$cell" != "$player_1" ]]; then
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
        if ! [[ "$move" =~ ^[1-9]$ ]]; then
            echo "Zła pozycja. Podaj liczbę od 1 do 9"
            echo ""
            continue
        fi
        
        local index=$(("$move" - 1))
        if [[ "${board[index]}" != "$player_2" && "${board[index]}" != "$player_1" ]]; then
            board[index]="$current_player"
            break
        else
            echo "Podana pozycja jest już zajęta"
            echo ""
        fi
    done
}

ai_move() {
    echo "Ruch komputera..."
    local possible_moves=()

    # Sprawdź czy istnieje wygrywający ruch
    for ((i = 0; i < ${#wins[@]}; i += 3)); do
        local a=${wins[i]}
        local b=${wins[i+1]}
        local c=${wins[i+2]}
        
        if [[ "${board[a]}" == "$player_2" && "${board[b]}" == "$player_2" && "${board[c]}" != "$player_2" && "${board[c]}" != "$player_1" ]]; then
            possible_moves+=( "$c" )
            break
        elif [[ "${board[a]}" == "$player_2" && "${board[c]}" == "$player_2" && "${board[b]}" != "$player_2" && "${board[b]}" != "$player_1" ]]; then
            possible_moves+=( "$b" )
            break
        elif [[ "${board[b]}" == "$player_2" && "${board[c]}" == "$player_2" && "${board[a]}" != "$player_2" && "${board[a]}" != "$player_1" ]]; then
            possible_moves+=( "$a" )
            break
        fi
    done
    if [[ ${#possible_moves[@]} != 0 ]]; then
        board[possible_moves[0]]="$current_player"
        return 0
    fi

    # Sprawdź czy gracz zaraz może wygrać (zablokuj go)
    for ((i = 0; i < ${#wins[@]}; i += 3)); do
        local a=${wins[i]}
        local b=${wins[i+1]}
        local c=${wins[i+2]}
        
        if [[ "${board[a]}" == "$player_1" && "${board[b]}" == "$player_1" && "${board[c]}" != "$player_1" && "${board[c]}" != "$player_2" ]]; then
            possible_moves+=( "$c" )
            break
        elif [[ "${board[a]}" == "$player_1" && "${board[c]}" == "$player_1" && "${board[b]}" != "$player_1" && "${board[b]}" != "$player_2" ]]; then
            possible_moves+=( "$b" )
            break
        elif [[ "${board[b]}" == "$player_1" && "${board[c]}" == "$player_1" && "${board[a]}" != "$player_1" && "${board[a]}" != "$player_2" ]]; then
            possible_moves+=( "$a" )
            break
        fi
    done
    if [[ ${#possible_moves[@]} != 0 ]]; then
        board[possible_moves[0]]="$current_player"
        return 0
    fi

    # Wykonaj losowy ruch z możliwej puli "wygrywalnych" ruchów
    for ((i = 0; i < ${#wins[@]}; i += 3)); do
        local a=${wins[i]}
        local b=${wins[i+1]}
        local c=${wins[i+2]}
        
        if [[ "${board[a]}" != "$player_1" && "${board[b]}" != "$player_1" && "${board[c]}" != "$player_1" ]]; then
            [[ "${board[a]}" != "$player_2" ]] && possible_moves+=( "$a" )
            [[ "${board[b]}" != "$player_2" ]] && possible_moves+=( "$b" )
            [[ "${board[c]}" != "$player_2" ]] && possible_moves+=( "$c" )
        fi
    done
    if [[ ${#possible_moves[@]} != 0 ]]; then
        local picked_cell="${possible_moves[$((RANDOM % ${#possible_moves[@]}))]}"
        board["$picked_cell"]="$current_player"
        return 0
    fi
    
    # Wykonaj losowy ruch
    for index in "${!board[@]}"; do
        if [[ "${board[$index]}" != "$player_1"  && "${board[$index]}" != "$player_2" ]]; then
            possible_moves+=( "$index" )
        fi
    done
    local picked_cell="${possible_moves[$((RANDOM % ${#possible_moves[@]}))]}"
    board["$picked_cell"]="$current_player"
}

player_switch() {
    if [[ "$current_player" == "$player_1" ]]; then
        current_player="$player_2"
    else
        current_player="$player_1"
    fi
}

save_game() {
    for cell in "${board[@]}"; do
        echo "$cell"
    done > "$save_file"
    echo "$current_player" >> "$save_file"
    echo "$is_ai_game" >> "$save_file"
    echo "Stan gry zapisany do: $save_file"
    echo ""
}

load_game() {
    if [[ ! -f "$save_file" ]]; then
        echo "Brak zapisanych stanów gry"
        echo ""
        return 1
    fi
    
    initialize_game
    mapfile -t saved < "$save_file"
    for i in {0..8}; do
        board[i]="${saved[i]}"
    done
    current_player="${saved[9]}"
    is_ai_game="${saved[10]}"
    echo "Wczytano stan gry z $save_file"
}

main_menu