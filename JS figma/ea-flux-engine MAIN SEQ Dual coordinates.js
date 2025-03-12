/* in panel MAIN, panel_MAIN.2SEQ_exp,
    select panel_MAIN.2SEQ and run the script below
*/

clear()

const s = figma.currentPage.findOne( node => node.name === 'repeated elements').children

let node_names = []

s.forEach( node => {
    node_names.push( node.name )
    
})

node_names.sort()

const s_children = figma.currentPage.selection[0].children

function traverse_node(node, name) {
    // Base case: If this node matches the name, return it
    if (node.name === name) {
        return { name: node.name, x: node.x, y: node.y, parent: node.parent };
    }
    
    // Check if the node has children
    if (node.children !== undefined && node.children.length > 0) {
        // Iterate through each child
        for (let child of node.children) {
            // Recursively traverse the child
            const result = traverse_node(child, name);
            // If a match is found in this branch, return it up the call stack
            if (result) {
                return result;
            }
        }
    }
    
    // If we reach here, no match was found in this branch
    return null;
}

let dual_seq_declarations = ''

node_names.forEach((name, i) => {
    let matchingNode = null;
    
    // Find first node in s that contains a child with matching name
    const container_node = s_children.find(node => {
        // Check if this node or any child node has the matching name
        matchingNode = traverse_node(node, name);
        return matchingNode !== null;
    });
    
    if (matchingNode) {
        console.log(name, matchingNode.x, matchingNode.y);
        const extra_width = ' '.repeat(35 - matchingNode.parent.name.length);
        const counter = i.toString().length > 1 ? i : i.toString().padStart(2, ' ')
        dual_seq_declarations += `{ ${matchingNode.name} }
SEQ.common_elements_data [ ${counter}, ELEMENT_UIID               ] := get_ui_id(${matchingNode.name.replace('_0_7','')})
SEQ.common_elements_data [ ${counter}, PANEL_DUAL_SEQ_PARENT_UIID ] := get_ui_id(${matchingNode.parent.name.replace('_exp','')})
SEQ.common_elements_data [ ${counter}, PANEL_DUAL_SEQ_X_COORD     ] := ${matchingNode.x}
SEQ.common_elements_data [ ${counter}, PANEL_DUAL_SEQ_Y_COORD     ] := ${matchingNode.y}\n`
    }
});

console.log(dual_seq_declarations)