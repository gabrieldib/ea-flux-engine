- user plays a key
- NCB plays the note immediately
- Listener counter is zeroed if note held count = 1 
- next LCB cycle fn007() is called to update block steps and ts
    - block index counter is updated (increased or decreased) depending on play direction
    - step duration is updated according to block step count
    - current block timestamps are calculated and populated into the timestamps array
    - fn25() update flux values on all blocks is called
        if we are at the start of all blocks cycle, 
            - call fn17 to get sequencer data per step
                - fn17() retrieves the original values input into the seq table
                - fn17() feed this value into fn34 to transform values from 0:10^6 to their domain scale
            - feed the returned values from fn17() into the fn022()` to get the 'fluxed' values, if applicable 
            - feed the returned values from fn22() into fn24 to populate the flux data arrays and update
                the current block::step::mod_target::picture_state accordingly
            - feed the flux step value into fn33() to make it dynamic according to the dyn slider 
            - finally populate teh data.dyn arrays with the fluxxed value

To reverse the data.dyn values into the original values, when either the flux rand power or flux rand local block
power buttons change state:

    - 