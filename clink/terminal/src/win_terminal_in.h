// Copyright (c) 2018 Martin Ridgers
// License: http://opensource.org/licenses/MIT

#pragma once

#include "terminal_in.h"

class input_idle;
class key_tester;

//------------------------------------------------------------------------------
class win_terminal_in
    : public terminal_in
{
public:
    virtual void    begin() override;
    virtual void    end() override;
    virtual void    select(input_idle* callback=nullptr) override;
    virtual int     read() override;
    virtual key_tester* set_key_tester(key_tester* keys) override;

private:
    unsigned int    get_dimensions();
    void            fix_console_input_mode();
    void            read_console(input_idle* callback=nullptr);
    void            process_input(const KEY_EVENT_RECORD& key_event);
    void            process_input(const MOUSE_EVENT_RECORD& mouse_event);
    void            filter_unbound_input(unsigned int buffer_count);
    void            push(unsigned int value);
    void            push(const char* seq);
    unsigned char   pop();
    key_tester*     m_keys;
    void*           m_stdin = nullptr;
    void*           m_stdout = nullptr;
    unsigned int    m_dimensions = 0;
    unsigned long   m_prev_mode = 0;
    DWORD           m_prev_mouse_button_state = 0;
    unsigned char   m_buffer_head = 0;
    unsigned char   m_buffer_count = 0;
    wchar_t         m_lead_surrogate = 0;
    unsigned char   m_buffer[16]; // must be power of two.
};
