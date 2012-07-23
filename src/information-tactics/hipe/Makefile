TARGET=main
CC=gcc
RM=rm
OBJ=$(TARGET).o
LIB=-lncurses

$(TARGET) : $(OBJ)
	$(CC) $(LIB) -o $(TARGET) $(OBJ)

clean:
	$(RM) $(OBJ)
	$(RM) $(TARGET)
