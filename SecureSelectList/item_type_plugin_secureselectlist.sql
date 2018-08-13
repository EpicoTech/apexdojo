prompt --application/set_environment
set define off verify off feedback off
whenever sqlerror exit sql.sqlcode rollback
--------------------------------------------------------------------------------
--
-- ORACLE Application Express (APEX) export file
--
-- You should run the script connected to SQL*Plus as the Oracle user
-- APEX_180100 or as the owner (parsing schema) of the application.
--
-- NOTE: Calls to apex_application_install override the defaults below.
--
--------------------------------------------------------------------------------
begin
wwv_flow_api.import_begin (
 p_version_yyyy_mm_dd=>'2018.04.04'
,p_release=>'18.1.0.00.45'
,p_default_workspace_id=>1540419811736702
,p_default_application_id=>100
,p_default_owner=>'PLUG-ADMIN'
);
end;
/
prompt --application/shared_components/plugins/item_type/secureselectlist
begin
wwv_flow_api.create_plugin(
 p_id=>wwv_flow_api.id(6214768511788133)
,p_plugin_type=>'ITEM TYPE'
,p_name=>'SECURESELECTLIST'
,p_display_name=>'SecureSelectList'
,p_supported_ui_types=>'DESKTOP'
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS:APEX_APPL_PAGE_IG_COLUMNS'
,p_plsql_code=>wwv_flow_string.join(wwv_flow_t_varchar2(
' procedure add_js (p_item   in            apex_plugin.t_item )',
'    IS',
' /******************************************************************************',
' Name: add_js ><(((*>~',
' Input: apex item',
' Purpose: Render cascading lov',
' ******************************************************************************/',
'BEGIN',
'apex_javascript.add_onload_code (',
'    p_code =>     ''''||',
'                  ''{apex.widget.selectList("#''||p_item.name||''",''||',
'                  ''{''||',
'                  apex_javascript.add_attribute(''ajaxIdentifier'',      apex_plugin.get_ajax_identifier)||',
'                  apex_javascript.add_attribute(''dependingOnSelector'', apex_plugin_util.page_item_names_to_jquery(p_item.lov_cascade_parent_items))||',
'                  apex_javascript.add_attribute(''optimizeRefresh'',     p_item.ajax_optimize_refresh)||',
'                  apex_javascript.add_attribute(''pageItemsToSubmit'',   apex_plugin_util.page_item_names_to_jquery(p_item.ajax_items_to_submit))||',
'                  apex_javascript.add_attribute(''nullValue'',           p_item.lov_null_value, false, false)||',
'                  ''});}'');',
'END add_js;',
'',
'procedure ajax (',
'    p_item   in            apex_plugin.t_item,',
'    p_plugin in            apex_plugin.t_plugin,',
'    p_param  in            apex_plugin.t_item_ajax_param,',
'    p_result in out nocopy apex_plugin.t_item_ajax_result )',
'/******************************************************************************',
' Name: ajax  ><(((*>~',
' Input: apex item',
' Returns:json ',
' Purpose: populate cascading lov',
' ******************************************************************************/   ',
'    is ',
'',
'    lv_parent_item varchar2(100);',
'    lv_sql varchar2(4000);',
'    lv_display_values_arr  apex_application_global.vc_arr2;',
'    lv_return_values_arr   apex_application_global.vc_arr2;',
'    begin',
'   ',
'      begin',
'        select Replace(lov_definition,'';'', '''')',
'              ,lov_cascade_parent_items',
'          into lv_sql',
'              ,lv_parent_item',
'          from apex_application_page_items ',
'         where application_id = v(''APP_ID'') ',
'           and page_id        = v(''APP_PAGE_ID'') ',
'           and item_name      = p_item.name;',
'       exception',
'         when no_data_found then',
'           lv_sql         := null;',
'           lv_parent_item := null;',
'      end;',
'    ',
'    EXECUTE IMMEDIATE lv_sql BULK COLLECT INTO   lv_display_values_arr',
'                                                ,lv_return_values_arr ',
'                                           USING v(lv_parent_item); ',
'                                           ',
'        apex_json.initialize_output(p_http_header => false);',
'        apex_json.open_object;',
'        apex_json.open_array(''values'');',
'',
'        for i in 1..lv_display_values_arr.count ',
'        loop ',
'          apex_json.open_object;',
'          apex_json.write(''d'', lv_display_values_arr(i));',
'          apex_json.write(''r'', lv_return_values_arr(i));',
'          apex_json.close_object;',
'        end loop;',
'',
'        apex_json.close_array;',
'        apex_json.write(''default'', v(p_item.name));',
'        apex_json.close_object;',
'end ajax;',
'    ',
'PROCEDURE get_plsql_values(',
'        p_plsql IN VARCHAR2,',
'        p_display_value_array OUT apex_application_global.vc_arr2,',
'        p_return_value_array  OUT apex_application_global.vc_arr2',
'    )',
'/******************************************************************************',
' Name: get_plsql_values ><(((*>~',
' Input: "PL/SQL" string',
' Returns: The display and return values from the pl/sql statment as arrays',
' Purpose: Handles selectlist with the option "function body returning sql query"',
' ******************************************************************************/',
'IS ',
'      lv_func_sql VARCHAR2(4000);',
'      lv_result_query VARCHAR2(4000);',
'      lv_semicolon VARCHAR2(1) default '';'';',
'BEGIN',
'lv_func_sql:=q''[',
'   DECLARE',
'    FUNCTION x RETURN VARCHAR2',
'        IS',
'    BEGIN ]''',
'    ||',
'      CASE WHEN p_plsql LIKE ''%;'' THEN p_plsql',
'        ELSE p_plsql || '';''',
'      END',
'    ||q''[ RETURN NULL; END;',
'',
'    BEGIN',
'    :wwv_flow.g_computation_result_vc := x;',
'    END;]'';',
'    EXECUTE IMMEDIATE(lv_func_sql) ',
'            USING OUT wwv_flow.g_computation_result_vc;',
'   ',
'    EXECUTE IMMEDIATE wwv_flow.g_computation_result_vc',
'            BULK COLLECT INTO p_display_value_array, ',
'                              p_return_value_array; ',
'END get_plsql_values;',
'',
'PROCEDURE get_static_values(',
'        p_string IN VARCHAR2,',
'        p_display_value_array OUT apex_application_global.vc_arr2,',
'        p_return_value_array  OUT apex_application_global.vc_arr2',
'    ) ',
'/******************************************************************************',
' Name: get_static_values ><(((*>~',
' Input: Takes a string seperated by commma,semicolon and split',
' Returns: The display and return values as arrays',
' Purpose: Used for static selectlist standalone or shared component ',
' ******************************************************************************/',
'IS ',
'    lv_string VARCHAR2(4000); ',
'BEGIN ',
'    lv_string := substr(p_string,instr(upper(p_string),''STATIC:'')+7);',
'    SELECT Max(CASE WHEN rn / 2 = Trunc(rn / 2) THEN y.str END) even, ',
'           Max(CASE WHEN rn / 2 != Trunc(rn / 2) THEN y.str END) odd ',
'           BULK COLLECT INTO p_display_value_array,',
'                             p_return_value_array ',
'    FROM   (SELECT ROWNUM + 1 rn, ',
'                   Trunc(( ROWNUM + 1 ) / 2) gb, ',
'                   z.str ',
'            FROM   XMLTABLE ( ''ora:tokenize($X, "\;|\,")'' passing (lv_string) AS x ',
'                   COLUMNS str VARCHAR2( 100) path ''.'' ) z) y ',
'           GROUP  BY y.gb; ',
'         ',
'END get_static_values;',
'/******************************************************************************',
' Name: get_static_lov_values ><(((*>~',
' Input: Item name',
' Returns: The display and return values for the lov as arrays',
' Purpose: Get the lov entries and create a commaseperated list call get_static_values',
'          which populates the arrays in the correct format',
' ******************************************************************************/',
'PROCEDURE get_static_lov_values(',
'        p_item_name IN wwv_flow_plugin_api.t_input_name,',
'        p_display_value_array  OUT apex_application_global.vc_arr2,',
'        p_return_value_array   OUT apex_application_global.vc_arr2',
'    ) ',
'IS ',
'     CURSOR get_lov_entries(p_item_name IN wwv_flow_plugin_api.t_input_name )',
'      IS',
'      SELECT Trim(Trailing from Listagg(display_value||'',''||return_value||'','')',
'                   WITHIN GROUP (ORDER BY NULL)) result',
'      FROM apex_application_page_items page_items,',
'           apex_application_lov_entries lov_entries',
'             WHERE page_items.application_id= V(''APP_ID'')',
'             AND page_items.page_id = V(''APP_PAGE_ID'')',
'             AND Replace(page_items.lov_definition,''.'','''')=To_char(lov_entries.lov_id)',
'             AND Upper(item_name) = Upper(p_item_name);',
'',
'      lv_result VARCHAR2(1000);',
'BEGIN ',
'',
'    FOR r1 in get_lov_entries(p_item_name) ',
'    LOOP',
'     lv_result:=r1.result;',
'    END LOOP;',
'    ',
'    get_static_values(lv_result,p_display_value_array,p_return_value_array);',
'            ',
'END get_static_lov_values;',
'',
'',
'/******************************************************************************',
' Name: render ><(((*>~',
' Purpose: Decide which type of selectlist. Get the data. Render the widget ',
' ******************************************************************************/           ',
'PROCEDURE render (',
'        p_item     IN apex_plugin.t_item,',
'        p_plugin   IN apex_plugin.t_plugin,',
'        p_param    IN apex_plugin.t_item_render_param,',
'        p_result   IN OUT NOCOPY apex_plugin.t_item_render_result',
'    ) IS',
'    CURSOR c_get_sql (p_item_name VARCHAR2,p_ig_col_id NUMBER) ',
'    IS --page item ',
'     SELECT lov_definition, ',
'            Instr(lov_definition, ''STATIC'', 1, 1) is_static,',
'            (select ''true'' from dual where  regexp_like(lov_definition, ''^(.*\s+)?return(\s+.*)?$'', ''i'') )is_plsql,',
'            Regexp_substr(lov_definition, ''^(.)'') is_static_lov,',
'            Nvl(lov_cascade_parent_items,''N'') is_cascade_lov, ',
'            lov_cascade_parent_items',
'    FROM   apex_application_page_items ',
'    WHERE  application_id = V(''APP_ID'') ',
'           AND page_id = V(''APP_PAGE_ID'') ',
'           AND Upper(item_name) = Upper(p_item_name)',
'    UNION ALL --interactive grid',
'    SELECT lov_source, ',
'           Instr(lov_source, ''STATIC'', 1, 1) is_static,',
'           (select ''true'' from dual where  regexp_like(lov_source, ''^(.*\s+)?return(\s+.*)?$'', ''i'') )is_plsql,',
'           Regexp_substr(lov_source, ''^(.)'') is_static_lov,',
'           Nvl(lov_cascade_parent_items,''N'') is_cascade_lov, ',
'           lov_cascade_parent_items',
'    FROM   apex_appl_page_ig_columns',
'    WHERE  application_id = V(''APP_ID'') ',
'           AND page_id = V(''APP_PAGE_ID'') ',
'           AND column_id = p_ig_col_id;',
'        ',
'    lv_item_name            wwv_flow_plugin_api.t_input_name;',
'    lv_sql                  VARCHAR2(4000);',
'    lv_static               BOOLEAN DEFAULT false;',
'    lv_plsql                BOOLEAN DEFAULT false;',
'    lv_static_lov           BOOLEAN DEFAULT false;',
'    lv_cascade_lov          BOOLEAN DEFAULT false;',
'    lv_display_values_arr   apex_application_global.vc_arr2;',
'    lv_return_values_arr    apex_application_global.vc_arr2;',
'    lv_parent_item          VARCHAR2(30);   ',
'    lv_ig_col_id            NUMBER;',
'    lv_item apex_plugin.t_item :=p_item;',
'BEGIN',
'   --get item_name , if IG you get the column_id',
'    ',
'   IF p_item.component_type_id=apex_component.c_comp_type_ig_column',
'   THEN',
'    lv_ig_col_id :=p_item.id;',
'   ELSE',
'    lv_item_name := apex_plugin.get_input_name_for_item;',
'   END IF;',
'    -- start to render',
'    sys.htp.prn(''<select ''',
'                || wwv_flow_plugin_util.get_element_attributes(lv_item,lv_item_name)',
'                || ''class="selectlist&#x20;apex-item-select" size="1">'');',
'        ',
'',
'     --get the statment and determine the type',
'    FOR r1 IN c_get_sql(lv_item_name,lv_ig_col_id) LOOP ',
'        IF r1.is_static = 1 THEN ',
'          lv_static := TRUE; ',
'        ELSIF r1.is_static_lov=''.'' THEN',
'          lv_static_lov:= TRUE;',
'        ELSIF r1.is_cascade_lov <>''N'' THEN',
'          lv_cascade_lov:=TRUE;',
'          lv_parent_item := r1.lov_cascade_parent_items;',
'        ELSIF r1.is_plsql = ''true'' THEN ',
'          lv_plsql := TRUE;',
'        END IF; ',
'        lv_sql := r1.lov_definition; ',
'    END LOOP; ',
'',
'    IF lv_static THEN',
'       get_static_values(lv_sql, lv_display_values_arr, lv_return_values_arr);',
'    ELSIF  lv_plsql THEN',
'     get_plsql_values(lv_sql, lv_display_values_arr, lv_return_values_arr);',
'    ELSIF lv_static_lov THEN',
'     get_static_lov_values(lv_item_name, lv_display_values_arr, lv_return_values_arr);',
'    ELSIF lv_cascade_lov THEN',
'     lv_sql := Replace(lv_sql, '';'', ''''); ',
'     EXECUTE IMMEDIATE lv_sql BULK COLLECT INTO  lv_display_values_arr, ',
'                                                 lv_return_values_arr ',
'                                                 USING V(lv_parent_item); ',
'    add_js(lv_item);',
'    ELSE',
'      lv_sql := Replace(lv_sql, '';'', ''''); ',
'      ',
'      EXECUTE IMMEDIATE lv_sql BULK COLLECT INTO lv_display_values_arr, ',
'                                                 lv_return_values_arr; ',
'    END IF; ',
'  ',
'    --render the rest of the widget',
'   sys.htp.prn('' <option value="" selected="selected" ></option>'');',
'    FOR i IN 1..lv_display_values_arr.COUNT LOOP ',
'        apex_plugin_util.Print_option(p_return_value => lv_return_values_arr(i), ',
'        p_display_value => lv_display_values_arr(i), ',
'        p_is_selected => case when lv_return_values_arr(i) = v(lv_item_name) then true else false end, ',
'        p_attributes => p_item.element_option_attributes, ',
'        p_escape => TRUE); ',
'    END LOOP; ',
'  ',
'  sys.htp.prn(''</select>'');',
'end render;',
'/******************************************************************************',
' Name: validation ><(((*>~',
' Purpose: Decide which type of selectlist. Get the data. Compare with the',
'          current client value.',
' ******************************************************************************/    ',
'PROCEDURE validation (  ',
'        p_item   IN apex_plugin.t_item,  ',
'        p_plugin IN apex_plugin.t_plugin,  ',
'        p_param  IN apex_plugin.t_item_validation_param,  ',
'        p_result IN OUT nocopy apex_plugin.t_page_item_validation_result',
'    ) IS',
'       ',
'    CURSOR c_get_sql (p_item_name VARCHAR2,p_ig_col_id NUMBER) ',
'    IS ',
'    SELECT  lov_definition, ',
'            Instr(lov_definition, ''STATIC'', 1, 1) is_static,',
'            (select ''true'' from dual where  regexp_like(lov_definition, ''^(.*\s+)?return(\s+.*)?$'', ''i'') )is_plsql,',
'            Regexp_substr(lov_definition, ''^(.)'') is_static_lov,',
'            Nvl(lov_cascade_parent_items,''N'') is_cascade_lov, ',
'            lov_cascade_parent_items',
'    FROM   apex_application_page_items ',
'    WHERE  application_id = V(''APP_ID'') ',
'           AND page_id = V(''APP_PAGE_ID'') ',
'           AND Upper(item_name) = Upper(p_item_name)',
'    UNION ALL --interactive grid',
'    SELECT lov_source, ',
'           Instr(lov_source, ''STATIC'', 1, 1) is_static,',
'           (select ''true'' from dual where  regexp_like(lov_source, ''^(.*\s+)?return(\s+.*)?$'', ''i'') )is_plsql,',
'           Regexp_substr(lov_source, ''^(.)'') is_static_lov,',
'           Nvl(lov_cascade_parent_items,''N'') is_cascade_lov, ',
'           lov_cascade_parent_items',
'    FROM   apex_appl_page_ig_columns',
'    WHERE  application_id = V(''APP_ID'') ',
'           AND page_id = V(''APP_PAGE_ID'') ',
'           AND column_id = p_ig_col_id;  ',
'        ',
'    lv_item_name          wwv_flow_plugin_api.t_input_name; ',
'    lv_type_id number;',
'    lv_sql                VARCHAR2(4000); ',
'    lv_static             BOOLEAN DEFAULT FALSE; ',
'    lv_plsql              BOOLEAN DEFAULT FALSE;',
'    lv_static_lov         BOOLEAN DEFAULT FALSE;',
'    lv_cascade_lov        BOOLEAN DEFAULT FALSE;',
'    lv_display_values_arr apex_application_global.vc_arr2; ',
'    lv_return_values_arr  apex_application_global.vc_arr2; ',
'    lv_match              NUMBER DEFAULT 0; ',
'    lv_count              NUMBER DEFAULT 0; ',
'    lv_custom_error       VARCHAR2(255) := p_item.attribute_01;',
'    lv_parent_item        VARCHAR2(30);',
'    lv_ig_col_id          NUMBER;',
'    ',
'BEGIN',
'  IF p_item.component_type_id=apex_component.c_comp_type_ig_column',
'   THEN',
'    lv_ig_col_id :=p_item.id;',
'  ELSE',
'    lv_item_name := p_item.name;',
'  END IF;',
'      --get the statment and determine the lov type',
'    FOR r1 IN c_get_sql(lv_item_name,lv_ig_col_id) LOOP ',
'        IF r1.is_static = 1 THEN ',
'          lv_static := TRUE; ',
'        ELSIF r1.is_static_lov=''.'' THEN',
'          lv_static_lov:= TRUE;',
'        ELSIF r1.is_cascade_lov <>''N'' THEN',
'          lv_parent_item := r1.lov_cascade_parent_items;',
'          lv_cascade_lov:=TRUE;',
'        ELSIF r1.is_plsql = ''true'' THEN ',
'          lv_plsql := TRUE; ',
'        END IF; ',
'        lv_sql := r1.lov_definition; ',
'    END LOOP; ',
'',
'    IF lv_static THEN',
'         get_static_values(lv_sql, lv_display_values_arr, lv_return_values_arr);',
'    ELSIF  lv_plsql THEN',
'     get_plsql_values(lv_sql, lv_display_values_arr, lv_return_values_arr);',
'    ELSIF lv_static_lov THEN',
'     get_static_lov_values(lv_item_name, lv_display_values_arr, lv_return_values_arr);',
'    ELSIF lv_cascade_lov THEN',
'      lv_sql := Replace(lv_sql, '';'', ''''); ',
'      EXECUTE IMMEDIATE lv_sql BULK COLLECT INTO lv_display_values_arr, ',
'                                                 lv_return_values_arr ',
'                                                 USING  V(lv_parent_item); ',
'      ',
'    ELSE',
'      lv_sql := Replace(lv_sql, '';'', ''''); ',
'      EXECUTE IMMEDIATE lv_sql BULK COLLECT INTO lv_display_values_arr, ',
'                                                 lv_return_values_arr; ',
'    END IF; ',
'      ',
'     ',
'    --Compare the current value with the selectlist ',
'    IF lv_return_values_arr.COUNT > 0 THEN',
'    FOR i IN 1..lv_return_values_arr.COUNT LOOP ',
'        IF NOT v(lv_item_name) = Lv_return_values_arr(i) THEN ',
'          lv_match := lv_match + 1; ',
'        END IF; ',
'    END LOOP; ',
'    ELSE',
'    lv_match:=-1;',
'    END IF;',
'    ',
'    lv_count := lv_return_values_arr.COUNT;',
'   ',
'    IF lv_count = lv_match THEN ',
'      apex_error.Add_error(p_message => lv_custom_error, ',
'      p_display_location => apex_error.c_on_error_page); ',
'    END IF; ',
'',
'end validation;'))
,p_api_version=>2
,p_render_function=>'render'
,p_ajax_function=>'ajax'
,p_validation_function=>'validation'
,p_standard_attributes=>'VISIBLE:FORM_ELEMENT:SESSION_STATE:SOURCE:LOV:CASCADING_LOV'
,p_substitute_attributes=>true
,p_subscribe_plugin_settings=>true
,p_version_identifier=>'1.0'
,p_files_version=>2
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(6214966514788136)
,p_plugin_id=>wwv_flow_api.id(6214768511788133)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>1
,p_display_sequence=>10
,p_prompt=>'Custom Error Message'
,p_attribute_type=>'TEXT'
,p_is_required=>true
,p_default_value=>'Something went wrong'
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(6215354849788138)
,p_plugin_id=>wwv_flow_api.id(6214768511788133)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>2
,p_display_sequence=>20
,p_prompt=>'Submit Page'
,p_attribute_type=>'PAGE ITEMS'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(6215705507788138)
,p_plugin_id=>wwv_flow_api.id(6214768511788133)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>3
,p_display_sequence=>30
,p_prompt=>'Redirect to page'
,p_attribute_type=>'PAGE NUMBER'
,p_is_required=>false
,p_supported_component_types=>'APEX_APPLICATION_PAGE_ITEMS'
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_attribute(
 p_id=>wwv_flow_api.id(6216183699788138)
,p_plugin_id=>wwv_flow_api.id(6214768511788133)
,p_attribute_scope=>'COMPONENT'
,p_attribute_sequence=>4
,p_display_sequence=>40
,p_prompt=>'Link to Target Page/URL'
,p_attribute_type=>'LINK'
,p_is_required=>false
,p_is_translatable=>false
);
wwv_flow_api.create_plugin_std_attribute(
 p_id=>wwv_flow_api.id(6217150283788141)
,p_plugin_id=>wwv_flow_api.id(6214768511788133)
,p_name=>'LOV'
);
end;
/
begin
wwv_flow_api.import_end(p_auto_install_sup_obj => nvl(wwv_flow_application_install.get_auto_install_sup_obj, false), p_is_component_import => true);
commit;
end;
/
set verify on feedback on define on
prompt  ...done
