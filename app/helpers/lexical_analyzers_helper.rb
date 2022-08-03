module LexicalAnalyzersHelper

  def class_of_char(char)
    abc =['a','b','c','d','e','f','g','h','e','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']
    dig = ['0','1','2','3','4','5','6','7','8','9']
    math = ['+','-','*','/','^','(',')']
    log = ['>','>=','<','<=','~']
    dot = ['.',':','=',';']

    if dot.find_all{ |elem| elem == char}.size !=0 then 'dot'
    elsif abc.find_all{ |elem| elem == char}.size !=0 then'Letter'
    elsif dig.find_all{ |elem| elem == char}.size !=0 then 'Digit'
    elsif math.find_all{ |elem| elem == char}.size !=0 then 'Math'
    elsif log.find_all{ |elem| elem == char}.size !=0 then 'Log'
    else 'other'
    end
  end

  def get_n_line(char)
    result=get_id(char)
    if result=='new_line'
      @n_line+=1
    else @n_line
    end
  end

  def get_idx_id(char)
    result=get_id(char)
    @idx_ident+=1 if (result=='identificator')
  end

  def get_idx_math(char)
    result=get_id(char)
    @idx_math+=1 if result=='real'||result=='integer'
  end

  def get_id(char)
    hook=Array.new
    char.split('').each do |item|
      hook.push(class_of_char(item))
    end
    if (hook.first=='Letter'&& (hook.include?('Math') ||  hook.include?('Log'))) then t('error.102')
    elsif (hook.first=='Letter') then get_lexem_type(char)
    elsif (hook.first=='Digit' && hook.include?('dot')&& hook.exclude?('Letter')&& hook.exclude?('Math')&& hook.exclude?('Log')) then 'real'
    elsif (hook.first=='Digit' && hook.exclude?('dot') && hook.exclude?('Letter')&& hook.exclude?('Math') && hook.exclude?('Log')) then 'integer'
    elsif (hook.first=='Digit' && hook.include?('dot')&& hook.include?('Letter')) then t('error.102')
    elsif hook.include?('dot') || hook.include?('Math') then get_lexem_type(char) #assign, order, etc
    elsif hook.include?('other') then  t('error.103')
    else t('error.104')
    end
  end

  def get_lexem_type(lexem)
    tokenHash = {
      'keyword' => ['program', 'begin', 'end', 'for', 'to', 'do', 'if', 'goto'],
      'add_op' => ['+','-'],
      'math_op' => ['*','/','^'],
      "log_op" => ['<','<=','>','>=','~', '='],
      'boolean' => ['true','false'],
      'assign' => [':='],
      'order_opp' => ['(', ')'],
      'new_line' => [';']
    }
    find_token = tokenHash.find {|key, values| values.include?(lexem)}
    if find_token !=nil
      find_token.first
    else 'identificator'
    end
  end

  def get_lexan(worddiv)
  hash_token ={}
  array_lexem = []
  worddiv.each do |item|
    hash_token[:num_line]=get_n_line(item)
    hash_token[:lexem_type] = get_id(item)
    hash_token[:lexema] = item
    hash_token[:idx] = get_idx_id(item) if hash_token[:lexem_type]=='identificator'
    hash_token[:idx] = get_idx_math(item) if hash_token[:lexem_type]=='real' || hash_token[:lexem_type]=='integer'
    array_lexem.push(hash_token)
    hash_token=Hash.new
  end
  return array_lexem
  end
################### SYNTAX ANALYSE ####################################
  def parser_start(lexan)
    if lexan.first[:lexem_type]=='keyword' && lexan.first[:lexema]=='program' && lexan.last[:lexem_type]=='keyword'&&lexan.last[:lexema]=='end'
      t('syntax.start.success')
    elsif lexan.first[:lexem_type]!='keyword' && lexan.last[:lexem_type]=='keyword'&&lexan.last[:lexema]=='end'
      t('syntax.start.fail_first')
    elsif lexan.first[:lexem_type]=='keyword' && lexan.first[:lexema]=='program'&& lexan.last[:lexem_type]!='keyword'
      t('syntax.start.fail_last')
    elsif lexan.first[:lexem_type]=='keyword' && lexan.first[:lexema]!='program' && lexan.last[:lexem_type]=='keyword'&&lexan.last[:lexema]=='end'
      t('syntax.start.fail_first')
    elsif lexan.first[:lexem_type]=='keyword' && lexan.first[:lexema]=='program' && lexan.last[:lexem_type]=='keyword'&&lexan.last[:lexema]!='end'
      t('syntax.start.fail_last')
    end
  end

  def parser_name(lexan)
    if parser_start(lexan)==t('syntax.start.success')&&lexan[1][:lexem_type]=='identificator'
      t('syntax.name.success')+"\"#{lexan[1][:lexema]}\""
    else
      t('syntax.name.fail')
    end
  end

  def parse_assign(lexan)
    assign_lines=Array.new
    ident_array=Array.new
    assign_array=Array.new
    lexan_without_name=lexan.drop(2)
### select hashes with assign
    assign_array=lexan_without_name.select {|v| v[:lexem_type]=='assign'}
### get number lines with assigning
    lexan_without_name.each do |hash|
      assign_lines.push(hash[:num_line]) if hash[:lexem_type]=='assign'
    end
### check syntax
    assign_lines.each do |assign_line|
      arr=lexan_without_name.select {|v| v[:num_line]==assign_line}
      arr=arr.drop(1) if arr.first[:lexem_type]=='new_line'
      return t('syntax.assign.fail')+"#{arr.first[:num_line]}" if arr.first[:lexem_type]!='identificator'
      return t('syntax.assign.fail')+"#{arr.first[:num_line]}" if arr[1][:lexem_type]!='assign'
      i=2
      while i<arr.length
        return t('syntax.assign.fail_expression')+"#{arr.first[:num_line]}" if arr[i][:lexem_type]=='keyword'
          ###### todo parse expression
        i+=1
      end
    end
    return t('syntax.assign.success')
  end

  def parse_if(lexan)
    if_lines=Array.new
    goto_lines=Array.new
    lexan_without_name=lexan.drop(2)
### get number lines with if and goto
    lexan_without_name.each do |hash|
      if_lines.push(hash[:num_line]) if hash[:lexema]=='if'
      goto_lines.push(hash[:num_line]) if hash[:lexema]=='goto'
    end
### check if_goto construction
    i=0
    while i<if_lines.length do
       return t('syntax.if.fail')+"#{if_lines[i]}" if if_lines!=goto_lines
       i+=1
     end
### check label as last symbol, goto as integer
     if_lines.each do |if_line|
       arr=lexan_without_name.select {|v| v[:num_line]==if_line}
       arr=arr.drop(1) if arr.first[:lexem_type]=='new_line'
       return t('syntax.if.fail_start')+"#{if_line}" if arr.first[:lexema]!='if'
       return t('syntax.if.fail_label')+"#{if_line}" if arr.last[:lexem_type]!='integer'
       return t('syntax.if.fail_goto')+"#{if_line}" if arr[arr.length-2][:lexema]!='goto'
       i=1
       while i<arr.length-2
         return t('syntax.if.fail_expression')+"#{arr.first[:num_line]}" if arr[i][:lexem_type]=='keyword'
           ###### todo parse expression
         i+=1
       end
     end
    return t('syntax.if.success')
  end
  def parse_for(lexan)
    for_lines=Array.new
    to_lines=Array.new
    do_lines=Array.new
    lexan_without_name=lexan.drop(2)
### get number lines with for, to do
    lexan_without_name.each do |hash|
      for_lines.push(hash[:num_line]) if hash[:lexema]=='for'
      to_lines.push(hash[:num_line]) if hash[:lexema]=='to'
      do_lines.push(hash[:num_line]) if hash[:lexema]=='do'
    end
### check for_to_do construction
    i=0
    while i<for_lines.length do
       return t('syntax.for.fail')+"#{for_lines[i]}" if for_lines!=to_lines
       return t('syntax.for.fail')+"#{for_lines[i]}" if to_lines!=do_lines
       i+=1
     end
 ### check end as last symbol, goto as integer
      for_lines.each do |for_line|
        arr=lexan_without_name.select {|v| v[:num_line]==for_line}
        arr=arr.drop(1) if arr.first[:lexem_type]=='new_line'
        return t('syntax.for.fail_start')+"#{for_line}" if arr.first[:lexema]!='for'
        return t('syntax.for.fail_end')+"#{for_line}" if arr.last[:lexema]!='end'

      end
     return t('syntax.for.success')
  end
end
