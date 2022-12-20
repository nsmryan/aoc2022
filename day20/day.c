#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <assert.h>
#include <math.h>

#define MAX_NUM_NODES 10000

typedef struct Node Node;

typedef struct Node {
    Node *prev;
    Node *next;
    int64_t num;
} Node;

int64_t wrap(int64_t i);
void walkNode(Node *node);
int64_t groveCoordinates(Node *node);
void printNodes(Node *node);

int64_t numNodes = 0;

int main(int argc, char *argv[]) {
    Node nodes[MAX_NUM_NODES];

    char numBuffer[64];
	int64_t zeroIndex = 0;
    while (fgets(numBuffer, sizeof(numBuffer), stdin) != NULL) {
        int64_t num = strtoll(numBuffer, NULL, 10);
        nodes[numNodes] = (Node){NULL, NULL, num};
        nodes[numNodes].num *= 811589153;

		if (num == 0) {
			zeroIndex = numNodes;
		}

        numNodes++;
    }

    // Link up nodes
	printf("linking nodes (%d)\n", numNodes);
    for (int64_t i = 0; i < numNodes; i++) {
		//printf("i - 1 = %d, i + 1 = %d\n", wrap(i - 1), wrap(i + 1));
        nodes[i].prev = &nodes[wrap(i - 1)];
        nodes[i].next = &nodes[wrap(i + 1)];
    }
	printf("initial node list\n");
	printNodes(&nodes[0]);
	assert(&nodes[0] == nodes[numNodes-1].next);
	assert(nodes[0].prev == &nodes[numNodes - 1]);

    for (int64_t times = 0; times < 10; times++) {
		printf("walking nodes (%d)\n", times);
		for (int64_t i = 0; i < numNodes; i++) {
			walkNode(&nodes[i]);
			//printf("Step %d (%d):\n", i, nodes[i].num);
			//printNodes(&nodes[0]);
		}
	}
	printNodes(&nodes[0]);

	printf("calculating coordinates\n");
	printf("Part 1: %lld\n", groveCoordinates(&nodes[zeroIndex]));


    return EXIT_SUCCESS;
}

int64_t wrap(int64_t i) {
    if (i < 0) {
        return numNodes + (i % numNodes);
    } else {
        return i % numNodes;
    }
}

int64_t groveCoordinates(Node *node) {
	int64_t coords = 0;

	for (int64_t i = 0; i < 1000; i++) {
		node = node->next;
	}
	printf("1000 %lld\n", node->num);
	coords += node->num;

	for (int64_t i = 0; i < 1000; i++) {
		node = node->next;
	}
	printf("2000 %lld\n", node->num);
	coords += node->num;

	for (int64_t i = 0; i < 1000; i++) {
		node = node->next;
	}
	printf("3000 %lld\n", node->num);
	coords += node->num;
	printf("coord %lld\n", coords);
	for (int64_t i = 0; i < 1000; i++) {
		node = node->next;
	}
	printf("4000 %lld\n", node->num);
	for (int64_t i = 0; i < 1000; i++) {
		node = node->next;
	}
	printf("5000 %lld\n", node->num);

	return coords;
}

void walkNode(Node *node) {
	int64_t num = node->num % (numNodes - 1);
	if (num > 0) {
		//num %= numNodes;
		//num = wrap(num - 1);
	//} else {
	//	num = -((abs(num + 1)) % numNodes);
	}

	if (num == 0) {
		return;
	}

	// unlink the current node.
	node->prev->next = node->next;
	node->next->prev = node->prev;

	Node *newPlace = node;
	while (num != 0) {
		if (num > 0) {
			newPlace = newPlace->next;
			num--;
		} else {
			newPlace = newPlace->prev;
			num++;
		}
	}

	if (node->num >= 0) {
		node->next = newPlace->next;
		node->prev = newPlace;
		newPlace->next->prev = node;
		newPlace->next = node;
	} else {
		node->next = newPlace;
		node->prev = newPlace->prev;
		newPlace->prev->next = node;
		newPlace->prev = node;
	}
}

void printNodes(Node *node) {
	Node *first = node;

	//printf("Printing nodes:\n");
	printf("%lld ", node->num);
	node = node->next;
	while (node != first) {
		printf("%lld ", node->num);
		node = node->next;
	}

	//printf("\n");
	//printf("%d ", node->num);
	//node = node->prev;
	//while (node != first) {
	//	printf("%d ", node->num);
	//	node = node->prev;
	//}
	printf("\n");
}
