'''
Conway's game of life

Any live cell with fewer than two live neighbours dies, as if by underpopulation.
Any live cell with two or three live neighbours lives on to the next generation.
Any live cell with more than three live neighbours dies, as if by overpopulation.
Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
'''
#random is needed for the cell seed.
import random
#time is needed to sleep the generation of next generations.
import time
#initializes the grid
grid = []
def creategrid(height, width):
    '''Initializes the grid with a random seed''' 
    height = int(height)
    width = int(width)
    while height > 0:
        row = []
        i = 0
        while i < width:
            row.append(random.randint(0,1))
            i += 1
        grid.append(row)
        height -= 1

def createnextgen():
    '''Generates the next generation'''
    #initializes the grid to transition to the next grid
    transitiongrid = []
    j = 0
    while j < len(grid):
        i = 0
        transitionrow = []
        while i < len(grid[j]):
            neighbours = 0
            newcell = 0
            #these next try-except statements serve to determine whether a position exists and if it has a live or dead cell
            try:
                if grid[j][i - 1] == 1:
                    neighbours += 1
            except IndexError:
                pass
            try:
                if grid[j][i + 1] == 1:
                    neighbours += 1
            except IndexError:
                pass
            try:
                if grid[j - 1][i - 1] == 1:
                    neighbours += 1
            except IndexError:
                pass
            try:
                if grid[j - 1][i] == 1:
                    neighbours += 1
            except IndexError:
                pass
            try:
                if grid[j - 1][i + 1] == 1:
                    neighbours += 1
            except IndexError:
                pass
            try:
                if grid[j + 1][i - 1] == 1:
                    neighbours += 1
            except IndexError:
                pass
            try:
                if grid[j + 1][i] == 1:
                    neighbours += 1
            except IndexError:
                pass
            try:
                if grid[j + 1][i + 1] == 1:
                    neighbours += 1
            except IndexError:
                pass
            #These if statements determine if a cell should die, remain alive, or become alive.
            if grid[j][i] == 0 and neighbours == 3:
                newcell = 1
            if grid[j][i] == 1 and 2 <= neighbours <= 3:
                newcell = 1
            if grid[j][i] == 1 and neighbours > 3:
                newcell = 0
            if grid[j][i] == 1 and neighbours < 2:
                newcell = 0
            transitionrow.append(newcell)
            i += 1
        transitiongrid.append(transitionrow)
        j += 1
    return transitiongrid
# Execution of the functions, defining the width and height and formatting the grid to blocks for readability
print('Welcome to Conway\'s game of life!\nPlease state the height you want the grid to be:')
heightinput = input()
print('What is the width of the grid?:')
widthinput = input()
print('\n')
creategrid(heightinput, widthinput)
generation = 0
while True:
    print('\nGeneration' + str(generation))
    grid = createnextgen()
    output = ''
    for row in grid:
        for character in row:
            if character == 0:
                output = output + '\u2593'
            else:
                output = output + '\u2591'
        output = output + '\n'
    print(output)
    time.sleep(1)
    generation += 1
