TARGET=foo
CC=gcc
RM=rm
OBJ=main.o \
	hipe.d/demo.o \
	hipe.d/div.o \
	hipe.d/mouse.o \
	hipe.d/nkurses.o \


LIB=-lncurses

$(TARGET) : $(OBJ)
	$(CC) $(LIB) -o $(TARGET) $(OBJ)

clean:
	$(RM) $(OBJ)
	$(RM) $(TARGET)
