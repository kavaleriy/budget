function getCenterNode(data) {
    var nodes = partition(data);
    for(i in nodes) {
        if(nodes[i].label == center_node.label && nodes[i].level == center_node.level) {
            if(center_node.parent) {
                if(center_node.parent.label == nodes[i].parent.label && center_node.parent.level == nodes[i].parent.level) {
                    return nodes[i];
                }
            } else {
                return nodes[i];
            }
        }
    }
    //console.log("node not found");
}
