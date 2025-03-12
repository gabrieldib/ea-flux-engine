/* in panel MAIN, panel_MAIN.SEQjoin,
    go in repeated elements and select all its elements,
    then run this script to generate the coordinates
*/
clear()
const s = figma.currentPage.selection

let data = []
let sorted_data = []

s.forEach( node => {
    data.push( 
        {
            name: node.name,
            x: node.x,
            y: node.y,
            parent: node.parent
        }
    )
    
})

let sorted_names = data.map( node => node.name ).sort()

// sorted_names.forEach( name => console.log(name))

sorted_names.forEach( name => {
    const node_data = data.find( e => e.name === name)
    sorted_data.push(node_data)
})

let all_names = ''
// sorted_data.forEach( node => all_names += node.name+'\n')

let all_declarations = ''
sorted_data.forEach( (node, i) => {
    const extra_width = ' '.repeat(40 - node.name.length);
    const counter = i.toString().length > 1 ? i : i.toString().padStart(2, ' ')
    const declaration = `{ ${node.name.replace("_0_7","")} }
SEQ.common_elements_data [ ${counter}, PANEL_JOIN_SEQ_PARENT_UIID ] := UIID_SEQ_JOIN_PANEL
SEQ.common_elements_data [ ${counter}, PANEL_JOIN_SEQ_X_COORD     ] := ${node.x}
SEQ.common_elements_data [ ${counter}, PANEL_JOIN_SEQ_Y_COORD     ] := ${node.y}\n`

    all_declarations += declaration
})

console.log(all_declarations)
