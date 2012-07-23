TARGET=main
CC=gcc
RM=rm
OBJS=main.o whatever.o foo/bar-baz.o

$(TARGET) : $(OBJS)
	$(CC) -o $(TARGET) $(OBJS)

clean:
	$(RM) $(OBJS)
	$(RM) $(TARGET)
