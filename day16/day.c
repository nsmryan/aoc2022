#include <stdio.h>
#include <stdint.h>
#include "info.c"

uint64_t completedCount = 0;
uint64_t shortCircuitCount = 0;
uint32_t globalMaxFlow = 0;

uint32_t step(uint32_t node, uint32_t enode, uint32_t minute, uint32_t eminute, uint32_t closed, uint32_t flow) {
    uint32_t maxFlow = flow;

#if 1
	uint32_t remainingRate = 0;
    for (uint32_t valveIndex = 0; valveIndex < numValves; valveIndex++) {
        if (((1 << valveIndex) & closed) == 0) {
			remainingRate += flowRates[valveIndex];
		}
	}

	uint32_t remainingMinute = minute;
	if (eminute < remainingMinute) {
		remainingMinute = eminute;
	}
	uint32_t remainingFlow = flow + (remainingRate * (27 - remainingMinute));
	if (remainingFlow < globalMaxFlow) {
		shortCircuitCount++;
		if ((shortCircuitCount % 100000000) == 0) {
			printf("short circuited %lld\n", shortCircuitCount);
		}
		return flow;
	}
#endif

    for (uint32_t valveIndex = 0; valveIndex < numValves; valveIndex++) {
        if (((1 << valveIndex) & closed) == 0) {
			uint32_t valveNode = valveToNode[valveIndex];
			uint32_t newClosed = closed | (1 << valveIndex);

			if (node != valveNode) {
                uint32_t index = node * numNodes + valveNode;
				uint32_t dist = dists[index];
				uint32_t newMinute = minute + dist;
                newMinute++;
				if (newMinute < 27) {
					uint32_t incrFlow = flowRates[valveIndex] * (27 - newMinute);
					uint32_t newFlow = flow + incrFlow;
					uint32_t resultFlow = step(valveNode, enode, newMinute, eminute, newClosed, newFlow);
					if (resultFlow > maxFlow) {
						maxFlow = resultFlow;
					}
				}
			}

			if (enode != valveNode) {
                uint32_t index = enode * numNodes + valveNode;
				uint32_t dist = dists[index];
				uint32_t newMinute = eminute + dist;
                newMinute++;
				if (newMinute < 27) {
					uint32_t incrFlow = flowRates[valveIndex] * (27 - newMinute);
					uint32_t newFlow = flow + incrFlow;
					uint32_t resultFlow = step(node, valveNode, minute, newMinute, newClosed, newFlow);
					if (resultFlow > maxFlow) {
						maxFlow = resultFlow;
					}
				}
			}
		}
    }

	completedCount++;
	if ((completedCount % 100000000) == 0) {
		printf("Completed %lld\n", completedCount);
	}
	if (globalMaxFlow < maxFlow) {
		globalMaxFlow = maxFlow;
		printf("new max flow %d\n", globalMaxFlow);
	}

    return maxFlow;
}

int main(int argc, char *argv[]) {
    printf("Part 2: %d\n", step(startNode, startNode, 1, 1, 0, 0));
}

