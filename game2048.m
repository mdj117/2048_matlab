global game_score
global game_over
game_score=0;
game_over=0;
grid=zeros(4,4);
grid=initial(grid);
while game_over~=1
    keypress=waitforbuttonpress;
    key=double(get(gcf,'CurrentCharacter'));
    %u 30, l 28, r 29, d 31
    switch key
        case 30
            grid=up(grid);
            game_over=game_over_check(grid);
        case 28
            grid=left(grid);
            game_over=game_over_check(grid);
        case 29
            grid=right(grid);
            game_over=game_over_check(grid);
        case 31
            grid=down(grid);
            game_over=game_over_check(grid);
    end
end

function [grid]=initial(grid)
    pos_1=randi(16);
    pos_2=randi(16);
    while pos_1==pos_2
        pos_1=randi(16);
        pos_2=randi(16);
    end
    positions=[pos_1 pos_2];
    for x=1:2
    chance=rand();
    if chance<0.9
        grid(positions(x))=2;
    else
        grid(positions(x))=4;
    end
    end
end

function [grid]=new(grid)
    pos=randi(16);
        while grid(pos)~=0
            pos=randi(16);
        end
    chance=rand();
    if chance<0.5
        grid(pos)=2;
    else
        grid(pos)=4;
    end
end

function [grid]=shift(grid)
    empty_mat=zeros(4,4);
    for x=1:4
        non_empty=1;
        for y=1:4
            if grid(x,y)~=0
                empty_mat(x,non_empty)=grid(x,y);
                non_empty=non_empty+1;
            end
        end
    end
    grid=empty_mat;
end

function [grid]=add(grid)
    for x=1:4
        for y=1:3
            if grid(x,y)~=0 && grid(x,y)==grid(x,y+1)
                grid(x,y)=2.*grid(x,y);
                grid(x,y+1)=0;
                global game_score;
                game_score=grid(x,y)+game_score;
            end
        end
    end
end

function [grid_left]=left(grid)
    grid_left=shift(add(shift(grid)));
    if isequal(grid_left,grid)==false
        grid_left=new(grid_left);
    end
end

function [grid_down]=down(grid)
    grid_down=transpose(fliplr(shift(add(shift(fliplr(transpose(grid)))))));
    if isequal(grid_down,grid)==false
        grid_down=new(grid_down);
    end
end

function [grid_right]=right(grid)
    grid_right=fliplr(shift(add(shift(fliplr(grid)))));
    if isequal(grid_right,grid)==false
        grid_right=new(grid_right);
    end
end

function [grid_up]=up(grid)
    grid_up=transpose(shift(add(shift(transpose(grid)))));
    if isequal(grid_up,grid)==false
        grid_up=new(grid_up);
    end
end

function [game_over]=game_over_check(grid)
    if isequal(grid,up(grid)) && isequal(grid,down(grid)) && isequal(grid,left(grid)) && isequal(grid,right(grid))
        global game_over
        game_over=1;
    else
        game_over=0;
    end
end