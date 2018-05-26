<?xml version='1.0'?>
<xsl:stylesheet version="2.0"
      xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
      xmlns:UML="org.omg.xmi.namespace.UML"
      xmlns:UML2 = "org.omg.xmi.namespace.UML2"
      xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
      xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
      xmlns:xsd="http://www.w3.org/2001/XMLSchema#" 
      xmlns:owl="http://www.w3.org/2002/07/owl#" >
<!--
OWLfromUML.xsl 
Version 1.1  2006/08/05 12:22
written by Sebastian Leinhos as a part of my master thesis 2006  
feel free to contact me: sebastian@ooyoo.de for any questions and suggestions
#################################################
Visit http://diplom.ooyoo.de for more information
#################################################
-->

<xsl:output method="xml" encoding="UTF-8"/>

<!-- Key definition for finding attributes/associations/dependencies (stereotypes) with identical name, used for First Class Concept of Datatype and ObjectProperties - see below -->
<xsl:key name="key_attribute_name" match="//UML:Namespace.ownedElement/UML:Class/UML:Classifier.feature/UML:Attribute" use="@name"/>
<xsl:key name="key_attribute_name_AC" match="//UML:Namespace.ownedElement/UML:AssociationClass/UML:Classifier.feature/UML:Attribute" use="@name"/>
<xsl:key name="key_association_name" match="//UML:Association" use="@name"/>
<xsl:key name="key_stereotype_name" match="//UML:Stereotype" use="@name"/>
<xsl:key name="key_role_name1" match="//UML:Association/UML:Association.connection/UML:AssociationEnd[1]" use="@name"/>
<xsl:key name="key_role_name2" match="//UML:Association/UML:Association.connection/UML:AssociationEnd[2]" use="@name"/>


<xsl:template match="/">

<rdf:RDF
xmlns ="http://owl.describing.uml#"
xml:base ="http://owl.from.uml#"
xmlns:owl ="http://www.w3.org/2002/07/owl#"
xmlns:rdf ="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
xmlns:xsd="http://www.w3.org/2001/XMLSchema#"  
xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" > 

  <xsl:element name="owl:Ontology">
    <xsl:attribute name="rdf:about"></xsl:attribute>
    <xsl:element name="rdfs:label">do not delete - created with xslt script "OWLfromUML.xsl" written by Sebastian Leinhos as a part of his master thesis 2006 - do not delete</xsl:element>
  </xsl:element> 
  
  
      <!-- ##################### -->
	  <!-- Handle Associationclasses -->
	  <!-- ##################### -->
	  
	  <!-- search vor every class -->
		<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass"> 	
		
		<!-- variables of the class, name and ID -->
		<xsl:variable name="class_name" select="@name" />
		<xsl:variable name="xmi_id" select="@xmi.id" />

		<!-- create new owl:Class element -->
          <xsl:element name="owl:Class">
          
          <!-- create new rdf:ID attribute, which is class name -->
            <xsl:attribute name="rdf:ID"><xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/></xsl:attribute> 
            
           
           
            
            
              <!-- for every generalization element add a subclass declaration-->
            <xsl:for-each select="UML:GeneralizableElement.generalization/UML:Generalization"> 
            
				<!-- call template with parameter of generalization id  -->
                <xsl:call-template name="get_parent">
                <xsl:with-param name="generalization_id"><xsl:value-of select="@xmi.idref"/></xsl:with-param>                
              </xsl:call-template>
              
            </xsl:for-each>
            <!-- end of generalization -->        
            
            
            
            <!-- ############################ -->
			 <!-- adding property restricitions to classes -->
			 <!-- ############################ -->           
            
			<!-- for every attribute of type DataType add a restriction and multiplicity-->
			<xsl:for-each select="UML:Classifier.feature/UML:Attribute/UML:StructuralFeature.type/UML:DataType">
			
			<xsl:call-template name="add_Property_toClass">
			</xsl:call-template>

			<!-- end of attribute search of type Datatype-->
			</xsl:for-each>
			
			
			<!-- for every attribute of type class add a restriction and multiplicity-->
			<xsl:for-each select="UML:Classifier.feature/UML:Attribute/UML:StructuralFeature.type/UML:Class">
			
			<xsl:call-template name="add_Property_toClass">
			</xsl:call-template>

			<!-- end of attribute search of type class -->
			</xsl:for-each>	
			
		
			
			
			
			<!--################### -->
			<!-- add isAssociationClass Property to Class -->
			<!-- ################## -->
			
			<xsl:element name="rdfs:subClassOf">
				<xsl:element name="owl:Restriction">
					<xsl:element name="owl:onProperty">
						<xsl:attribute name="rdf:resource">#isAssociationClass</xsl:attribute>
					</xsl:element>	
                                        <xsl:element name="owl:cardinality">
				                <xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:attribute>1</xsl:element>			
				</xsl:element>			
			</xsl:element>
			
			
			<!-- search for every association where current class is domain of it (associationEnd position = 1-->
			<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[position()=1]/UML:AssociationEnd.participant/UML:AssociationClass[@xmi.idref=$xmi_id]">			
					
			<xsl:call-template name="add_ObjectProperty_toClass">
				<xsl:with-param name="association_name"><xsl:value-of select="../../../../@name" /></xsl:with-param>
				<xsl:with-param name="class_name"><xsl:value-of select="$class_name" /></xsl:with-param>
				<xsl:with-param name="association_id"><xsl:value-of select="../../../../@xmi.id" /></xsl:with-param>
				<xsl:with-param name="lower"><xsl:value-of select="../../../UML:AssociationEnd[position() = 2]/UML:AssociationEnd.multiplicity/UML:Multiplicity/UML:Multiplicity.range/UML:MultiplicityRange/@lower" /></xsl:with-param>
				<xsl:with-param name="upper"><xsl:value-of select="../../../UML:AssociationEnd[position() = 2]/UML:AssociationEnd.multiplicity/UML:Multiplicity/UML:Multiplicity.range/UML:MultiplicityRange/@upper" /></xsl:with-param>
				<xsl:with-param name="is_navigable1"><xsl:value-of select="../../../UML:AssociationEnd[position() = 1]/@isNavigable" /></xsl:with-param>
				<xsl:with-param name="is_navigable2"><xsl:value-of select="../../../UML:AssociationEnd[position() = 2]/@isNavigable" /></xsl:with-param>
				<xsl:with-param name="role_name1"><xsl:value-of select="../../../UML:AssociationEnd[position() = 2]/@name" /></xsl:with-param>
			</xsl:call-template>
			
			<!-- end of association search -->
			</xsl:for-each>
			
			<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[position()=2]/UML:AssociationEnd.participant/UML:AssociationClass[@xmi.idref=$xmi_id]">			
					
			<xsl:call-template name="add_ObjectProperty_toClass_inverseOf">
				<xsl:with-param name="association_name"><xsl:value-of select="../../../../@name" /></xsl:with-param>
				<xsl:with-param name="class_name"><xsl:value-of select="$class_name" /></xsl:with-param>
				<xsl:with-param name="association_id"><xsl:value-of select="../../../../@xmi.id" /></xsl:with-param>
				<xsl:with-param name="lower"><xsl:value-of select="../../../UML:AssociationEnd[position() = 1]/UML:AssociationEnd.multiplicity/UML:Multiplicity/UML:Multiplicity.range/UML:MultiplicityRange/@lower" /></xsl:with-param>
				<xsl:with-param name="upper"><xsl:value-of select="../../../UML:AssociationEnd[position() = 1]/UML:AssociationEnd.multiplicity/UML:Multiplicity/UML:Multiplicity.range/UML:MultiplicityRange/@upper" /></xsl:with-param>
				<xsl:with-param name="is_navigable1"><xsl:value-of select="../../../UML:AssociationEnd[position() = 1]/@isNavigable" /></xsl:with-param>
				<xsl:with-param name="is_navigable2"><xsl:value-of select="../../../UML:AssociationEnd[position() = 2]/@isNavigable" /></xsl:with-param>
				<xsl:with-param name="role_name2"><xsl:value-of select="../../../UML:AssociationEnd[position() = 1]/@name" /></xsl:with-param>
			</xsl:call-template>
			
			<!-- end of association search -->
			</xsl:for-each>

            		<xsl:call-template name="createAssociationClassEndPropertyRestriction">
				<xsl:with-param name="firstClass_xmi.idref"><xsl:value-of select="UML:Association.connection/UML:AssociationEnd[position()=1]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:with-param>
				<xsl:with-param name="secondClass_xmi.idref"><xsl:value-of select="UML:Association.connection/UML:AssociationEnd[position()=2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:with-param>
			</xsl:call-template>


           <!-- close owl:class element --> 
          </xsl:element>       
       
    
    </xsl:for-each>
    
    <xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass">
    
			<!-- call template to add first and second ObjectPropertys of AssociationClass -->			
			<xsl:call-template name="add_associationClass_op">
				<xsl:with-param name="associationClass_name"><xsl:value-of select="@name" /></xsl:with-param>
				<xsl:with-param name="firstClass_xmi.idref"><xsl:value-of select="UML:Association.connection/UML:AssociationEnd[position()=1]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:with-param>
				<xsl:with-param name="secondClass_xmi.idref"><xsl:value-of select="UML:Association.connection/UML:AssociationEnd[position()=2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:with-param>
			</xsl:call-template> 
			
	 </xsl:for-each>



<!-- ############################ -->
<!-- Adding owl:DatatypeProperty with name "isAssociationClass" -->
<!-- ############################ -->
<xsl:choose>

<!--check if there is only one Associationclass -->
<xsl:when test="count(//UML:Namespace.ownedElement/UML:AssociationClass)=1">

<xsl:element name="owl:DatatypeProperty">
	<xsl:attribute name="rdf:ID">isAssociationClass</xsl:attribute>
	
	<!-- find every AssociationClass and add it to domain -->
	
	<xsl:element name="rdfs:domain">
					
			<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass">		
			<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/></xsl:attribute>
			</xsl:for-each>
		
	<!-- end of rdfs:domain -->
	</xsl:element>	
	
	<!-- adding range of property which consists of an one element list with content "true"-->
	<xsl:element name="rdfs:range">
		<xsl:element name="owl:DataRange">
			<xsl:element name="owl:oneOf">
				<xsl:element name="rdf:List">
					<xsl:element name="rdf:first">
						<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#boolean</xsl:attribute>true</xsl:element>				
					<xsl:element name="rdf:rest">
						<xsl:attribute name="rdf:resource">http://www.w3.org/1999/02/22-rdf-syntax-ns#nil</xsl:attribute>
					</xsl:element>					
				</xsl:element>					
			</xsl:element>		
		</xsl:element>
	</xsl:element>

<!-- end of adding owl:DatatypeProperty -->
</xsl:element>

</xsl:when>

<!--check if there are at least two AssociationClasses -->
<xsl:when test="count(//UML:Namespace.ownedElement/UML:AssociationClass)>1">

<xsl:element name="owl:DatatypeProperty">
	<xsl:attribute name="rdf:ID">isAssociationClass</xsl:attribute>
	
	<!-- find every AssociationClass and add it to domain -->
	
	<xsl:element name="rdfs:domain">
		<xsl:element name="owl:Class">				
				<!-- create unionOf element -->
				<xsl:element name="owl:unionOf">				
						<!-- create parseType attribute with value Collection -->
						<xsl:attribute name="rdf:parseType">Collection</xsl:attribute>
						
						<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass">
								
									<xsl:element name="owl:Class">
										<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/></xsl:attribute>
									</xsl:element>
								
						</xsl:for-each>
												
				</xsl:element>
		</xsl:element>	
	<!-- end of rdfs:domain -->
	</xsl:element>	
	
	<!-- adding range of property which consists of an one element list with content "true"-->
	<xsl:element name="rdfs:range">
		<xsl:element name="owl:DataRange">
			<xsl:element name="owl:oneOf">
				<xsl:element name="rdf:List">
					<xsl:element name="rdf:first">
						<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#boolean</xsl:attribute>true</xsl:element>				
					<xsl:element name="rdf:rest">
						<xsl:attribute name="rdf:resource">http://www.w3.org/1999/02/22-rdf-syntax-ns#nil</xsl:attribute>
					</xsl:element>
				</xsl:element>			
			</xsl:element>						
		</xsl:element>
	</xsl:element>

<!-- end of adding owl:DatatypeProperty -->
</xsl:element>

</xsl:when>
</xsl:choose>



	<!-- ################################# -->
	<!-- Handle Classes and Generalization -->
	<!-- ################################ -->
	
		<!-- search vor every class -->
		<xsl:for-each select="//UML:Namespace.ownedElement/UML:Class"> 	
		
		<xsl:variable name="stereotype_xmi.idref"><xsl:value-of select="UML:ModelElement.stereotype/UML:Stereotype/@xmi.idref" /></xsl:variable>

		<xsl:if test="not(//UML:Stereotype[@xmi.id=$stereotype_xmi.idref]/@name='DataType') and not(@name='String') and not(@name='Short') and not(@name='Long') and not(@name='Date') and not(@name='Byte') and not(@name='Boolean') and not(@name='Character') and not(@name='Double') and not(@name='Float') and not(@name='Integer') and not(@name='String') and not(@name='Time') and not(@name='URL') and not(@name='String')  ">

	
		<!-- variables of the class, name and ID -->
		<xsl:variable name="class_name" select="@name" />
		<xsl:variable name="xmi_id" select="@xmi.id" />

		<!-- create new owl:Class element -->
          <xsl:element name="owl:Class">
          
          <!-- create new rdf:ID attribute, which is class name -->
            <xsl:attribute name="rdf:ID"><xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/></xsl:attribute>         
            
             <!-- is Class abstract then add DatatypeProperty "isAbstract" to this class -->
            <xsl:if test="@isAbstract='true' ">
				<xsl:element name="rdfs:subClassOf">
					<xsl:element name="owl:Restriction">
						<xsl:element name="owl:onProperty">
							<xsl:attribute name="rdf:resource">#isAbstract</xsl:attribute>
						</xsl:element>
						<xsl:element name="owl:cardinality">
							<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#int</xsl:attribute>1</xsl:element>
					</xsl:element>
				</xsl:element>
            </xsl:if>         
            
            
            <!-- for every generalization element add a subclass declaration-->
            <xsl:for-each select="UML:GeneralizableElement.generalization/UML:Generalization"> 
            
				<!-- call template with parameter of generalization id  -->
                <xsl:call-template name="get_parent">
                <xsl:with-param name="generalization_id"><xsl:value-of select="@xmi.idref"/></xsl:with-param>                
              </xsl:call-template>
              
            </xsl:for-each>
            <!-- end of generalization -->              
            
            
            
            <!-- for every abstraction element add a subclass declaration when Interface realization otherwise just add subClassOf Dependency-->
            <xsl:for-each select="UML:ModelElement.clientDependency/UML:Abstraction">
            
				<!-- call template with parameter of dependency id -->
				<xsl:call-template name="get_dependent_classes">
					<xsl:with-param name="dependency_id"><xsl:value-of select="@xmi.idref" /></xsl:with-param>
			    </xsl:call-template>				            
            
            <!-- end of dependency search -->
            </xsl:for-each>
            
            
            
 <!-- ############################ -->
 <!-- adding property restricitions to classes -->
 <!-- ############################ -->           
            
			<!-- for every attribute of type DataType add a restriction and multiplicity-->
			<xsl:for-each select="UML:Classifier.feature/UML:Attribute/UML:StructuralFeature.type/UML:DataType">
			
			<xsl:call-template name="add_Property_toClass">
			</xsl:call-template>

			<!-- end of attribute search of type Datatype-->
			</xsl:for-each>
			
			
			<!-- for every attribute of type class add a restriction and multiplicity-->
			<xsl:for-each select="UML:Classifier.feature/UML:Attribute/UML:StructuralFeature.type/UML:Class">
			
			<xsl:call-template name="add_Property_toClass">
			</xsl:call-template>

			<!-- end of attribute search of type class -->
			</xsl:for-each>		
			
			<!-- for every attribute of type AssociationClass add a restriction and multiplicity-->
			<xsl:for-each select="UML:Classifier.feature/UML:Attribute/UML:StructuralFeature.type/UML:AssociationClass">
			
			<xsl:call-template name="add_Property_toClass">
			</xsl:call-template>

			<!-- end of attribute search of type class -->
			</xsl:for-each>
			
				
			<!-- search for every association where current class is domain of it (associationEnd position = 1-->
			<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[position()=1]/UML:AssociationEnd.participant/UML:Class[@xmi.idref=$xmi_id]">			
					
			<xsl:call-template name="add_ObjectProperty_toClass">
				<xsl:with-param name="association_name"><xsl:value-of select="../../../../@name" /></xsl:with-param>
				<xsl:with-param name="class_name"><xsl:value-of select="$class_name" /></xsl:with-param>
				<xsl:with-param name="association_id"><xsl:value-of select="../../../../@xmi.id" /></xsl:with-param>
				<xsl:with-param name="lower"><xsl:value-of select="../../../UML:AssociationEnd[position() = 2]/UML:AssociationEnd.multiplicity/UML:Multiplicity/UML:Multiplicity.range/UML:MultiplicityRange/@lower" /></xsl:with-param>
				<xsl:with-param name="upper"><xsl:value-of select="../../../UML:AssociationEnd[position() = 2]/UML:AssociationEnd.multiplicity/UML:Multiplicity/UML:Multiplicity.range/UML:MultiplicityRange/@upper" /></xsl:with-param>
				<xsl:with-param name="is_navigable1"><xsl:value-of select="../../../UML:AssociationEnd[position() = 1]/@isNavigable" /></xsl:with-param>
				<xsl:with-param name="is_navigable2"><xsl:value-of select="../../../UML:AssociationEnd[position() = 2]/@isNavigable" /></xsl:with-param>
				<xsl:with-param name="role_name1"><xsl:value-of select="../../../UML:AssociationEnd[position() = 2]/@name" /></xsl:with-param>
			</xsl:call-template>
			
			<!-- end of association search -->
			</xsl:for-each>
						
			

			
			<!-- search for every association where current class is range of it (associationEnd position = 2-->
			<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[position()=2]/UML:AssociationEnd.participant/UML:Class[@xmi.idref=$xmi_id]">
				
				<!-- variable for association name -->
				<xsl:variable name="association_name"><xsl:value-of select="../../../../@name" /></xsl:variable>		
						
			<xsl:call-template name="add_ObjectProperty_toClass_inverseOf">
				<xsl:with-param name="association_name"><xsl:value-of select="../../../../@name" /></xsl:with-param>
				<xsl:with-param name="class_name"><xsl:value-of select="$class_name" /></xsl:with-param>
				<xsl:with-param name="association_id"><xsl:value-of select="../../../../@xmi.id" /></xsl:with-param>
				<xsl:with-param name="lower"><xsl:value-of select="../../../UML:AssociationEnd[position() = 1]/UML:AssociationEnd.multiplicity/UML:Multiplicity/UML:Multiplicity.range/UML:MultiplicityRange/@lower" /></xsl:with-param>
				<xsl:with-param name="upper"><xsl:value-of select="../../../UML:AssociationEnd[position() = 1]/UML:AssociationEnd.multiplicity/UML:Multiplicity/UML:Multiplicity.range/UML:MultiplicityRange/@upper" /></xsl:with-param>
				<xsl:with-param name="is_navigable1"><xsl:value-of select="../../../UML:AssociationEnd[position() = 1]/@isNavigable" /></xsl:with-param>
				<xsl:with-param name="is_navigable2"><xsl:value-of select="../../../UML:AssociationEnd[position() = 2]/@isNavigable" /></xsl:with-param>				
				<xsl:with-param name="role_name2"><xsl:value-of select="../../../UML:AssociationEnd[position() = 1]/@name" /></xsl:with-param>				

			</xsl:call-template>

			<!-- end of association search -->
			</xsl:for-each>	    
			
			
			
	 <!-- ############################# -->
    <!-- Handle dependencies of class -->
    <!-- ############################# --> 
    
    <xsl:for-each select="UML:ModelElement.clientDependency/UML:Dependency">
    
    <xsl:variable name="dependency_xmi.idref"><xsl:value-of select="@xmi.idref" /></xsl:variable>
    
    		<xsl:call-template name="add_dependencies_toClass">
				<xsl:with-param name="dependency_xmi.idref"><xsl:value-of select="@xmi.idref" /></xsl:with-param>
				<xsl:with-param name="class_name"><xsl:value-of select="../../@name" /></xsl:with-param>
				<xsl:with-param name="class_id"><xsl:value-of select="../../@xmi.id" /></xsl:with-param>
				<xsl:with-param name="stereotype_xmi.idref"><xsl:value-of select="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:ModelElement.stereotype/UML:Stereotype/@xmi.idref" /></xsl:with-param>
				<xsl:with-param name="client_class_xmi.idref"><xsl:value-of select="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:Dependency.client/UML:Class/@xmi.idref" /></xsl:with-param>
				<xsl:with-param name="supplier_class_xmi.idref"><xsl:value-of select="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:Dependency.supplier/UML:Class/@xmi.idref" /></xsl:with-param>
                                <xsl:with-param name="supplier_interface_xmi.idref"><xsl:value-of select="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:Dependency.supplier/UML:Interface/@xmi.idref" /></xsl:with-param>
			</xsl:call-template>
    
    </xsl:for-each>       
            
           <!-- close owl:class element --> 
          </xsl:element>        
          
    	</xsl:if>		   
    
    </xsl:for-each>
    <!-- End of handle UML Classes -->  
    

    
    
    
    <!-- ############## -->
    <!-- Handle Interfaces -->
    <!-- ############## -->   
    
    <!-- search for every interface -->
    <xsl:for-each select="//UML:Namespace.ownedElement/UML:Interface">
    
		<!-- create owl:class element from interface-->
		<xsl:element name="owl:Class">
		
			<!-- create new attribute which is class (interface) name -->
			<xsl:attribute name="rdf:ID"><xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
			    
		

                       <!-- for every generalization element add a subclass declaration-->
                       <xsl:for-each select="UML:GeneralizableElement.generalization/UML:Generalization"> 
            
		     		<!-- call template with parameter of generalization id  -->
                                <xsl:call-template name="createInterfaceParent">
                                      <xsl:with-param name="generalization_id"><xsl:value-of select="@xmi.idref"/></xsl:with-param>                
                               </xsl:call-template>
              
                       </xsl:for-each>
                       <!-- end of generalization --> 
 
		<!-- close owl:class element -->
		</xsl:element>

    <!-- End of handle Interfaces -->
    </xsl:for-each>  



<!-- ############################-->
<!-- Handle ObjectProperties with no association name  -->
<!-- ########################### -->   

	<xsl:for-each select="//UML:Association.connection">

	<xsl:variable name="association_name" select="../@name"/>
	<xsl:variable name="association_xmi.id" select="../@xmi.id" />
	
	<xsl:variable name="class_domain_idref" select="UML:AssociationEnd[position() = 1]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" />
	<xsl:variable name="class_domain_AC_idref" select="UML:AssociationEnd[position() = 1]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" />
	<xsl:variable name="class_range_idref" select="UML:AssociationEnd[position() = 2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" />	
	<xsl:variable name="class_range_AC_idref" select="UML:AssociationEnd[position() = 2]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" />	
	<xsl:variable name="interface_range_idref" select="UML:AssociationEnd[position() = 2]/UML:AssociationEnd.participant/UML:Interface/@xmi.idref" />	
	

	<xsl:variable name="domain" select="//UML:Class[$class_domain_idref=@xmi.id]/@name" />
	<xsl:variable name="domain_AC" select="//UML:Namespace.ownedElement/UML:AssociationClass[$class_domain_AC_idref=@xmi.id]/@name" />
	<xsl:variable name="range_class" select="//UML:Class[@xmi.id=$class_range_idref]/@name" />
	<xsl:variable name="range_AC" select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$class_range_AC_idref]/@name" />
	<xsl:variable name="range_interface" select="//UML:Interface[@xmi.id=$interface_range_idref]/@name" />
	
	<xsl:variable name="is_navigable1" select="UML:AssociationEnd[position() = 1]/@isNavigable"/>
	<xsl:variable name="is_navigable2" select="UML:AssociationEnd[position() = 2]/@isNavigable"/>
	
		<xsl:call-template name="unnamed_ObjectProperties" >
			<xsl:with-param name="association_name"><xsl:value-of select="$association_name" /></xsl:with-param>
			<xsl:with-param name="association_xmi.id"><xsl:value-of select="$association_xmi.id" /></xsl:with-param>
			<xsl:with-param name="domain"><xsl:value-of select="$domain" /></xsl:with-param>
			<xsl:with-param name="domain_AC"><xsl:value-of select="$domain_AC" /></xsl:with-param>
			<xsl:with-param name="range_class"><xsl:value-of select="$range_class" /></xsl:with-param>
			<xsl:with-param name="range_AC"><xsl:value-of select="$range_AC" /></xsl:with-param>
			<xsl:with-param name="range_interface"><xsl:value-of select="$range_interface" /></xsl:with-param>
			<xsl:with-param name="class_domain_idref"><xsl:value-of select="$class_domain_idref" /></xsl:with-param>
			<xsl:with-param name="class_range_idref"><xsl:value-of select="$class_range_idref" /></xsl:with-param>
			<xsl:with-param name="class_range_AC_idref"><xsl:value-of select="$class_range_AC_idref" /></xsl:with-param>
			<xsl:with-param name="interface_range_idref"><xsl:value-of select="$interface_range_idref" /></xsl:with-param>
			<xsl:with-param name="is_navigable1"><xsl:value-of select="$is_navigable1" /></xsl:with-param>
			<xsl:with-param name="is_navigable2"><xsl:value-of select="$is_navigable2" /></xsl:with-param>
			<xsl:with-param name="role_name1"><xsl:value-of select="UML:AssociationEnd[1]/@name" /></xsl:with-param>
			<xsl:with-param name="role_name2"><xsl:value-of select="UML:AssociationEnd[2]/@name" /></xsl:with-param>
		</xsl:call-template>
	
	</xsl:for-each>  	
	
<!-- ############################ -->
<!-- Adding owl:ObjectProperty for aggrgeation and composition when unnamed -->
<!-- ############################ -->
<xsl:choose>

<!--check if there are more aggregations or compositions -->
<xsl:when test="(count(//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite'])) + (count(//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate'])) > 1">

<!-- add consits_of property -->
<xsl:element name="owl:ObjectProperty">
	<xsl:attribute name="rdf:ID">consists_of</xsl:attribute>
		<xsl:element name="rdfs:domain">
			<xsl:element name="owl:Class">
				<xsl:element name="owl:unionOf">
				<xsl:attribute name="rdf:parseType">Collection</xsl:attribute>
		
				<!-- find every class which participate in composition as a whole -->
				<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite'] ">
				
					<xsl:variable name="whole_xmi.idref"><xsl:value-of select="UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:variable>
				
						<xsl:for-each select="//UML:Class[@xmi.id=$whole_xmi.idref]">
					
							<xsl:element name="owl:Class">
								<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
							</xsl:element>
					
						</xsl:for-each>	


				</xsl:for-each>
				
				<!-- find every class which participate in aggregation as a whole -->
				<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate'] ">

					<xsl:variable name="whole_xmi.idref"><xsl:value-of select="UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:variable>
				
						<xsl:for-each select="//UML:Class[@xmi.id=$whole_xmi.idref]">
					
							<xsl:element name="owl:Class">
								<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
							</xsl:element>
					
						</xsl:for-each>	


				</xsl:for-each>


				<!-- find every association class which participate in composition as a whole -->
				<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite'] ">
				
					<xsl:variable name="whole_xmi.idref"><xsl:value-of select="UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" /></xsl:variable>
				
						<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$whole_xmi.idref]">
					
							<xsl:element name="owl:Class">
								<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
							</xsl:element>
					
						</xsl:for-each>	


				</xsl:for-each>
				
				<!-- find every association class which participate in aggregation as a whole -->
				<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate'] ">

					<xsl:variable name="whole_xmi.idref"><xsl:value-of select="UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" /></xsl:variable>
				
						<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$whole_xmi.idref]">
					
							<xsl:element name="owl:Class">
								<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
							</xsl:element>
					
						</xsl:for-each>	


				</xsl:for-each>
			
				<!-- end of owl:unionOf -->
				</xsl:element>
			<!-- end of owl:Class -->
			</xsl:element>		
		<!-- end of rdfs:domain -->
		</xsl:element>	
	
		<!-- adding range of property which consists of an one element list with content "true"-->
		<xsl:element name="rdfs:range">
			<xsl:element name="owl:Class">
				<xsl:element name="owl:unionOf">
					<xsl:attribute name="rdf:parseType">Collection</xsl:attribute>
					
					
						<!-- find every class which participate in composition as a part -->
						<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite']">
						
							<xsl:variable name="part_xmi.idref"><xsl:value-of select="../UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:variable>
							
								<xsl:for-each select="//UML:Class[@xmi.id=$part_xmi.idref]">
								
									<xsl:element name="owl:Class">
										<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
									</xsl:element>
								
								</xsl:for-each>						
						
						</xsl:for-each>	
					
						<!-- find every class which participate in aggregation as a part -->
						<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate']">
						
							<xsl:variable name="part_xmi.idref"><xsl:value-of select="../UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:variable>
							
								<xsl:for-each select="//UML:Class[@xmi.id=$part_xmi.idref]">
								
									<xsl:element name="owl:Class">
										<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
									</xsl:element>
								
								</xsl:for-each>						
						
						</xsl:for-each>	

						<!-- find every association class which participate in composition as a part -->
						<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite']">
						
							<xsl:variable name="part_xmi.idref"><xsl:value-of select="../UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" /></xsl:variable>
							
								<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$part_xmi.idref]">
								
									<xsl:element name="owl:Class">
										<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
									</xsl:element>
								
								</xsl:for-each>						
						
						</xsl:for-each>	
					
						<!-- find every association class which participate in aggregation as a part -->
						<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate']">
						
							<xsl:variable name="part_xmi.idref"><xsl:value-of select="../UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" /></xsl:variable>
							
								<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$part_xmi.idref]">
								
									<xsl:element name="owl:Class">
										<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
									</xsl:element>
								
								</xsl:for-each>						
						
						</xsl:for-each>				
						
					<!-- end of owl:unionOf -->	
					</xsl:element>			
				<!-- end of owl:Class -->
				</xsl:element>		
			<!-- end of rdfs:range -->
			</xsl:element>
			
			<xsl:element name="owl:inverseOf">
				<xsl:attribute name="rdf:resource">#is_part_of</xsl:attribute>
			</xsl:element>
			
<!-- end of adding owl:ObjectProperty consits_of-->
</xsl:element>	


<!-- add is_part_of  property -->
<xsl:element name="owl:ObjectProperty">
	<xsl:attribute name="rdf:ID">is_part_of</xsl:attribute>
		<xsl:element name="rdfs:domain">
			<xsl:element name="owl:Class">
				<xsl:element name="owl:unionOf">
				<xsl:attribute name="rdf:parseType">Collection</xsl:attribute>
		
				<!-- find every class which participate in composition as a part -->
				<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite'] ">
				
					<xsl:variable name="whole_xmi.idref"><xsl:value-of select="../UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:variable>
				
						<xsl:for-each select="//UML:Class[@xmi.id=$whole_xmi.idref]">
					
							<xsl:element name="owl:Class">
								<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
							</xsl:element>
					
						</xsl:for-each>	


				</xsl:for-each>
				
				<!-- find every class which participate in aggregation as a part -->
				<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate'] ">

					<xsl:variable name="whole_xmi.idref"><xsl:value-of select="../UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:variable>
				
						<xsl:for-each select="//UML:Class[@xmi.id=$whole_xmi.idref]">
					
							<xsl:element name="owl:Class">
								<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
							</xsl:element>
					
						</xsl:for-each>	


				</xsl:for-each>

				<!-- find every association class which participate in composition as a part -->
				<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite'] ">
				
					<xsl:variable name="whole_xmi.idref"><xsl:value-of select="../UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" /></xsl:variable>
				
						<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$whole_xmi.idref]">
					
							<xsl:element name="owl:Class">
								<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
							</xsl:element>
					
						</xsl:for-each>	


				</xsl:for-each>
				
				<!-- find every association class which participate in aggregation as a part -->
				<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate'] ">

					<xsl:variable name="whole_xmi.idref"><xsl:value-of select="../UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" /></xsl:variable>
				
						<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$whole_xmi.idref]">
					
							<xsl:element name="owl:Class">
								<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
							</xsl:element>
					
						</xsl:for-each>	


				</xsl:for-each>
			
				<!-- end of owl:unionOf -->
				</xsl:element>
			<!-- end of owl:Class -->
			</xsl:element>		
		<!-- end of rdfs:domain -->
		</xsl:element>	
	
		<!-- adding range of property -->
		<xsl:element name="rdfs:range">
			<xsl:element name="owl:Class">
				<xsl:element name="owl:unionOf">
					<xsl:attribute name="rdf:parseType">Collection</xsl:attribute>
					
					
						<!-- find every class which participate in composition as a whole -->
						<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite']">
						
							<xsl:variable name="part_xmi.idref"><xsl:value-of select="UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:variable>
							
								<xsl:for-each select="//UML:Class[@xmi.id=$part_xmi.idref]">
								
									<xsl:element name="owl:Class">
										<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
									</xsl:element>
								
								</xsl:for-each>						
						
						</xsl:for-each>	
					
						<!-- find every class which participate in aggregation as a whole -->
						<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate']">
						
							<xsl:variable name="part_xmi.idref"><xsl:value-of select="UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:variable>
							
								<xsl:for-each select="//UML:Class[@xmi.id=$part_xmi.idref]">
								
									<xsl:element name="owl:Class">
										<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
									</xsl:element>
								
								</xsl:for-each>						
						
						</xsl:for-each>	

						<!-- find every association class which participate in composition as a whole -->
						<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite']">
						
							<xsl:variable name="part_xmi.idref"><xsl:value-of select="UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" /></xsl:variable>
							
								<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$part_xmi.idref]">
								
									<xsl:element name="owl:Class">
										<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
									</xsl:element>
								
								</xsl:for-each>						
						
						</xsl:for-each>	
					
						<!-- find every association class which participate in aggregation as a whole -->
						<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate']">
						
							<xsl:variable name="part_xmi.idref"><xsl:value-of select="UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" /></xsl:variable>
							
								<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$part_xmi.idref]">
								
									<xsl:element name="owl:Class">
										<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
									</xsl:element>
								
								</xsl:for-each>						
						
						</xsl:for-each>					
						
					<!-- end of owl:unionOf -->	
					</xsl:element>			
				<!-- end of owl:Class -->
				</xsl:element>		
			<!-- end of rdfs:range -->
			</xsl:element>
			
			<xsl:element name="owl:inverseOf">
				<xsl:attribute name="rdf:resource">#consists_of</xsl:attribute>
			</xsl:element>
			
<!-- end of adding owl:ObjectProperty is_part_of -->
</xsl:element>	
	
</xsl:when>


<!-- otherwise there are more is only one aggregation or composition -->
<xsl:when test="(count(//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite'])) + (count(//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate'])) = 1">

<!-- add consits_of property -->
<xsl:element name="owl:ObjectProperty">
	<xsl:attribute name="rdf:ID">consists_of</xsl:attribute>
		<xsl:element name="rdfs:domain">
		
				<!-- find every class which participate in composition as a whole -->
				<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite'] ">
				
					<xsl:variable name="whole_xmi.idref"><xsl:value-of select="UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:variable>
				
						<xsl:for-each select="//UML:Class[@xmi.id=$whole_xmi.idref]">					
							
								<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>							
					
						</xsl:for-each>	


				</xsl:for-each>
				
				<!-- find every class which participate in aggregation as a whole -->
				<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate'] ">

					<xsl:variable name="whole_xmi.idref"><xsl:value-of select="UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:variable>
				
						<xsl:for-each select="//UML:Class[@xmi.id=$whole_xmi.idref]">
					
							
								<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>							
					
						</xsl:for-each>	

				</xsl:for-each>	

				<!-- find every association class which participate in composition as a whole -->
				<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite'] ">
				
					<xsl:variable name="whole_xmi.idref"><xsl:value-of select="UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" /></xsl:variable>
				
						<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$whole_xmi.idref]">					
							
								<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>							
					
						</xsl:for-each>	


				</xsl:for-each>
				
				<!-- find every association class which participate in aggregation as a whole -->
				<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate'] ">

					<xsl:variable name="whole_xmi.idref"><xsl:value-of select="UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" /></xsl:variable>
				
						<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$whole_xmi.idref]">
					
							
								<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>							
					
						</xsl:for-each>	

				</xsl:for-each>	
		

		<!-- end of rdfs:domain -->
		</xsl:element>	
	
		<!-- adding range of property which consists of an one element list with content "true"-->
		<xsl:element name="rdfs:range">
			
	
						<!-- find every class which participate in composition as a part -->
						<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite']">
						
							<xsl:variable name="part_xmi.idref"><xsl:value-of select="../UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:variable>
							
								<xsl:for-each select="//UML:Class[@xmi.id=$part_xmi.idref]">
								
									
										<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>								
								
								</xsl:for-each>						
						
						</xsl:for-each>	
					
						<!-- find every class which participate in aggregation as a part -->
						<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate']">
						
							<xsl:variable name="part_xmi.idref"><xsl:value-of select="../UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:variable>
							
								<xsl:for-each select="//UML:Class[@xmi.id=$part_xmi.idref]">
								
								
										<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
									
								
								</xsl:for-each>						
						
						</xsl:for-each>	


						<!-- find every assiciation class which participate in composition as a part -->
						<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite']">

							<xsl:variable name="part_xmi.idref"><xsl:value-of select="../UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" /></xsl:variable>
							
								<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$part_xmi.idref]">
								
									
										<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>								
								
								</xsl:for-each>						
						
						</xsl:for-each>	
					
						<!-- find every assiciation class which participate in aggregation as a part -->
						<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate']">

							<xsl:variable name="part_xmi.idref"><xsl:value-of select="../UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" /></xsl:variable>
							
								<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$part_xmi.idref]">
								
								
										<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
									
								
								</xsl:for-each>						
						
						</xsl:for-each>					
						
			<!-- end of rdfs:range -->
			</xsl:element>
			
			<xsl:element name="owl:inverseOf">
				<xsl:attribute name="rdf:resource">#is_part_of</xsl:attribute>
			</xsl:element>
			
<!-- end of adding owl:ObjectProperty consits_of-->
</xsl:element>	


<!-- add is_part_of  property -->
<xsl:element name="owl:ObjectProperty">
	<xsl:attribute name="rdf:ID">is_part_of</xsl:attribute>
		<xsl:element name="rdfs:domain">
					
				<!-- find every class which participate in composition as a part -->
				<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite'] ">
				
					<xsl:variable name="whole_xmi.idref"><xsl:value-of select="../UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:variable>
				
						<xsl:for-each select="//UML:Class[@xmi.id=$whole_xmi.idref]">					
							
								<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>							
					
						</xsl:for-each>	


				</xsl:for-each>
				
				<!-- find every class which participate in aggregation as a part -->
				<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate'] ">

					<xsl:variable name="whole_xmi.idref"><xsl:value-of select="../UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:variable>
				
						<xsl:for-each select="//UML:Class[@xmi.id=$whole_xmi.idref]">
												
								<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
												
						</xsl:for-each>	

				</xsl:for-each>
			


				<!-- find every association class which participate in composition as a part -->
				<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite'] ">
				
					<xsl:variable name="whole_xmi.idref"><xsl:value-of select="../UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" /></xsl:variable>
				
						<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$whole_xmi.idref]">					
							
								<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>							
					
						</xsl:for-each>	


				</xsl:for-each>
				
				<!-- find every association class which participate in aggregation as a part -->
				<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate'] ">

					<xsl:variable name="whole_xmi.idref"><xsl:value-of select="../UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" /></xsl:variable>
				
						<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$whole_xmi.idref]">
												
								<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
												
						</xsl:for-each>	

				</xsl:for-each>

		<!-- end of rdfs:domain -->
		</xsl:element>	
	
		<!-- adding range of property -->
		<xsl:element name="rdfs:range">
								
					
						<!-- find every class which participate in composition as a whole -->
						<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite']">
						
							<xsl:variable name="part_xmi.idref"><xsl:value-of select="UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:variable>
							
								<xsl:for-each select="//UML:Class[@xmi.id=$part_xmi.idref]">								
									
										<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>									
								
								</xsl:for-each>						
						
						</xsl:for-each>	
					
						<!-- find every class which participate in aggregation as a whole -->
						<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate']">
						
							<xsl:variable name="part_xmi.idref"><xsl:value-of select="UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:variable>
							
								<xsl:for-each select="//UML:Class[@xmi.id=$part_xmi.idref]">								
									
										<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>									
								
								</xsl:for-each>						
						
						</xsl:for-each>				
						

						<!-- find every association class which participate in composition as a whole -->
						<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite']">
						
							<xsl:variable name="part_xmi.idref"><xsl:value-of select="UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" /></xsl:variable>
							
								<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$part_xmi.idref]">								
									
										<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>									
								
								</xsl:for-each>						
						
						</xsl:for-each>	
					
						<!-- find every association class which participate in aggregation as a whole -->
						<xsl:for-each select="//UML:Association/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate']">
						
							<xsl:variable name="part_xmi.idref"><xsl:value-of select="UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" /></xsl:variable>
							
								<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$part_xmi.idref]">								
									
										<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>									
								
								</xsl:for-each>						
						
						</xsl:for-each>	

			<!-- end of rdfs:range -->
			</xsl:element>
			
			<xsl:element name="owl:inverseOf">
				<xsl:attribute name="rdf:resource">#consists_of</xsl:attribute>
			</xsl:element>
			
<!-- end of adding owl:ObjectProperty is_part_of -->
</xsl:element>	
	
</xsl:when>

</xsl:choose>


	
<!-- ############################-->
<!-- Handle DatatypeProperties, which are UML attributes of type Datatype  -->
<!-- one have to declare a DataType in Poseidon (i.e DataType Int), use Stereotype <<DataType>> when using a class or use java.lang.int -->
<!-- ########################### -->    

	<!-- for every attribute element with same name -->
		<xsl:for-each select="//UML:Attribute[generate-id(.)=generate-id(key('key_attribute_name', @name)[1])]">
		
			<!-- sort attributes descending due to their names -->
			<xsl:sort select="@name" order="descending" />
			
			<!-- save current attribute name in variable -->
			<xsl:variable name="attribute_name_of_key" select="@name" />
			
			<!-- id of the class the attribute is referring to -->
			<xsl:variable name="class_idref" select="current()/UML:StructuralFeature.type/UML:Class/@xmi.idref" />	
			
			<!-- id of the associationClass the attribute is referring to -->
			<xsl:variable name="AC_idref" select="current()/UML:StructuralFeature.type/UML:AssociationClass/@xmi.idref" />	
			
			<!-- id of the Datatype the attribute is referring to -->
			<xsl:variable name="idref" select="current()/UML:StructuralFeature.type/UML:DataType/@href" />	
				
	
			<xsl:call-template name="op_or_dp_decision">
				<xsl:with-param name="idref"><xsl:value-of select="$idref" /></xsl:with-param>
				<xsl:with-param name="class_idref"><xsl:value-of select="$class_idref" /></xsl:with-param>
				<xsl:with-param name="AC_idref"><xsl:value-of select="$AC_idref" /></xsl:with-param>
				<xsl:with-param name="attribute_name_of_key"><xsl:value-of select="$attribute_name_of_key" /></xsl:with-param>
			</xsl:call-template>	
	
						
	<!-- end of every attribute with same name -->
	</xsl:for-each>  
	
	
	<!-- do the same for attributes of associationClasses -->	
	<!-- NOTE: Attributes in AssociationClasses and normal Classes have to have a different name!!! -->
	<!-- for every attribute element with same name -->
		<xsl:for-each select="//UML:Attribute[generate-id(.)=generate-id(key('key_attribute_name_AC', @name)[1])]">
		
			<!-- sort attributes descending due to their names -->
			<xsl:sort select="@name" order="descending" />
			
			<!-- save current attribute name in variable -->
			<xsl:variable name="attribute_name_of_key" select="@name" />
			
			<!-- id of the class the attribute is referring to -->
			<xsl:variable name="class_idref" select="current()/UML:StructuralFeature.type/UML:Class/@xmi.idref" />	
			
			<!-- id of the associationClass the attribute is referring to -->
			<xsl:variable name="AC_idref" select="current()/UML:StructuralFeature.type/UML:AssociationClass/@xmi.idref" />	
			
			<!-- id of the Datatype the attribute is referring to -->
			<xsl:variable name="idref" select="current()/UML:StructuralFeature.type/UML:DataType/@href" />
				
			<xsl:call-template name="op_or_dp_decision">
				<xsl:with-param name="idref"><xsl:value-of select="$idref" /></xsl:with-param>
				<xsl:with-param name="class_idref"><xsl:value-of select="$class_idref" /></xsl:with-param>
				<xsl:with-param name="AC_idref"><xsl:value-of select="$AC_idref" /></xsl:with-param>
				<xsl:with-param name="attribute_name_of_key"><xsl:value-of select="$attribute_name_of_key" /></xsl:with-param>
			</xsl:call-template>			
						
	<!-- end of every attribute with same name -->
	</xsl:for-each>  
	
	
	
<!-- ############################ -->
<!-- Adding owl:DatatypeProperty with name "isAbstract" -->
<!-- ############################ -->
<xsl:choose>

<!--check if there is only one abstract class -->
<xsl:when test="count(//UML:Class[@isAbstract='true'])=1">



<xsl:element name="owl:DatatypeProperty">
	<xsl:attribute name="rdf:ID">isAbstract</xsl:attribute>
	
	<!-- find every abstract class and add it to domain -->
	
	<xsl:element name="rdfs:domain">
					
			<xsl:for-each select="//UML:Class[@isAbstract='true']">		
			<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/></xsl:attribute>
			</xsl:for-each>
		
	<!-- end of rdfs:domain -->
	</xsl:element>	
	
	<!-- adding range of property which consists of an one element list with content "true"-->
	<xsl:element name="rdfs:range">
		<xsl:element name="owl:DataRange">
			<xsl:element name="owl:oneOf">
				<xsl:element name="rdf:List">
					<xsl:element name="rdf:first">
						<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#boolean</xsl:attribute>true</xsl:element>				
					<xsl:element name="rdf:rest">
						<xsl:attribute name="rdf:resource">http://www.w3.org/1999/02/22-rdf-syntax-ns#nil</xsl:attribute>
					</xsl:element>					
				</xsl:element>					
			</xsl:element>		
		</xsl:element>
	</xsl:element>

<!-- end of adding owl:DatatypeProperty -->
</xsl:element>

</xsl:when>

<!--check if there are at least two abstract classes -->
<xsl:when test="count(//UML:Class[@isAbstract='true'])>1">

<xsl:element name="owl:DatatypeProperty">
	<xsl:attribute name="rdf:ID">isAbstract</xsl:attribute>
	
	<!-- find every abstract class and add it to domain -->
	
	<xsl:element name="rdfs:domain">
		<xsl:element name="owl:Class">				
				<!-- create unionOf element -->
				<xsl:element name="owl:unionOf">				
						<!-- create parseType attribute with value Collection -->
						<xsl:attribute name="rdf:parseType">Collection</xsl:attribute>
						
						<xsl:for-each select="//UML:Class[@isAbstract='true']">
								
									<xsl:element name="owl:Class">
										<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/></xsl:attribute>
									</xsl:element>
								
						</xsl:for-each>
												
				</xsl:element>
		</xsl:element>	
	<!-- end of rdfs:domain -->
	</xsl:element>	
	
	<!-- adding range of property which consists of an one element list with content "true"-->
	<xsl:element name="rdfs:range">
		<xsl:element name="owl:DataRange">
			<xsl:element name="owl:oneOf">
				<xsl:element name="rdf:List">
					<xsl:element name="rdf:first">
						<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#boolean</xsl:attribute>true</xsl:element>				
					<xsl:element name="rdf:rest">
						<xsl:attribute name="rdf:resource">http://www.w3.org/1999/02/22-rdf-syntax-ns#nil</xsl:attribute>
					</xsl:element>
				</xsl:element>			
			</xsl:element>						
		</xsl:element>
	</xsl:element>

<!-- end of adding owl:DatatypeProperty -->
</xsl:element>

</xsl:when>
</xsl:choose>



<!-- ############################ -->
<!-- Adding owl:ObjectProperty with name "Dependency" -->
<!-- ############################ -->

<xsl:choose>


<!--check if there is only one dependency -->
<xsl:when test="count(//UML:Class/UML:ModelElement.clientDependency/UML:Dependency)=1">

<xsl:variable name="dependency_xmi.idref"><xsl:value-of select="//UML:Class/UML:ModelElement.clientDependency/UML:Dependency/@xmi.idref" /></xsl:variable>
<xsl:variable name="domain_class_xmi.idref"><xsl:value-of select="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:Dependency.client/UML:Class/@xmi.idref" /></xsl:variable>
<xsl:variable name="range_class_xmi.idref"><xsl:value-of select="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:Dependency.supplier/UML:Class/@xmi.idref" /></xsl:variable>
<xsl:variable name="range_interface_xmi.idref"><xsl:value-of select="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:Dependency.supplier/UML:Interface/@xmi.idref" /></xsl:variable>


<xsl:element name="owl:ObjectProperty">
	<xsl:attribute name="rdf:ID">Dependency</xsl:attribute>
	
	<!-- find class which participate at this particular dependency and add it to domain -->
	
	<xsl:element name="rdfs:domain">
			
			<xsl:for-each select="//UML:Class[@xmi.id=$domain_class_xmi.idref]">
			<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/></xsl:attribute>
			</xsl:for-each>
			<xsl:for-each select="//UML:Interface[@xmi.id=$domain_class_xmi.idref]">
			<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/></xsl:attribute>
			</xsl:for-each>
	
	<!-- end of rdfs:domain -->
	</xsl:element>	
	
	<!-- adding range of property which consists of an one element list with content "true"-->
	<xsl:element name="rdfs:range">
			
			<xsl:for-each select="//UML:Class[@xmi.id=$range_class_xmi.idref]">
			<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/></xsl:attribute>
			</xsl:for-each>
			<xsl:for-each select="//UML:Interface[@xmi.id=$range_interface_xmi.idref]">
			<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/></xsl:attribute>
			</xsl:for-each>
	</xsl:element>

<!-- end of adding owl:ObjectProperty -->
</xsl:element>


	<!-- get stereotype - if exists - and add subClassOf ObjectProperty with name of stereotype as a subClassOf dependency -->
	<xsl:variable name="stereotype_xmi.idref"><xsl:value-of select="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:ModelElement.stereotype/UML:Stereotype/@xmi.idref" /></xsl:variable>

	<!-- only add it, if stereotype exists -->
	<xsl:if test="not($stereotype_xmi.idref='')">

	<xsl:element name="owl:ObjectProperty">
		<xsl:attribute name="rdf:ID"><xsl:value-of select="//UML:Stereotype[@xmi.id=$stereotype_xmi.idref]/@name"/></xsl:attribute>
		<xsl:element name="rdfs:subPropertyOf">
			<xsl:attribute name="rdf:resource">#Dependency</xsl:attribute>
		</xsl:element>
			<xsl:element name="rdfs:domain">
			
				<xsl:for-each select="//UML:Class[@xmi.id=$domain_class_xmi.idref]">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/></xsl:attribute>		
				</xsl:for-each>
				<xsl:for-each select="//UML:Interface[@xmi.id=$domain_class_xmi.idref]">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/></xsl:attribute>		
				</xsl:for-each>
				
			</xsl:element>
			<xsl:element name="rdfs:range">
			
				<xsl:for-each select="//UML:Class[@xmi.id=$range_class_xmi.idref]">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/></xsl:attribute>
				</xsl:for-each>
				<xsl:for-each select="//UML:Interface[@xmi.id=$range_interface_xmi.idref]">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/></xsl:attribute>
				</xsl:for-each>
			</xsl:element>
		
	<!-- end of owl:ObjectProperty -->	
	</xsl:element>

	</xsl:if>
</xsl:when>


<!-- otherwise check if there is more than one dependency -->
<xsl:when test="count(//UML:Class/UML:ModelElement.clientDependency/UML:Dependency)> 1">

<xsl:element name="owl:ObjectProperty">
	<xsl:attribute name="rdf:ID">Dependency</xsl:attribute>

	<xsl:element name="rdfs:domain">
		<xsl:element name="owl:Class">
			<xsl:element name="owl:unionOf">
				<xsl:attribute name="rdf:parseType">Collection</xsl:attribute>


					<!-- get every class which participate at a dependency -->
					<xsl:for-each select="//UML:Class/UML:ModelElement.clientDependency/UML:Dependency">
						<xsl:variable name="dependency_xmi.idref"><xsl:value-of select="@xmi.idref" /></xsl:variable>
						
							<xsl:for-each select="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:Dependency.client/UML:Class">							
								<xsl:variable name="client_xmi.idref"><xsl:value-of select="@xmi.idref" /></xsl:variable>					
						
								<xsl:for-each select="//UML:Class[@xmi.id=$client_xmi.idref]">
								<xsl:element name="owl:Class">
									<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
								</xsl:element>
								</xsl:for-each>
								
							</xsl:for-each>	
							<xsl:for-each select="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:Dependency.client/UML:Interface">							
								<xsl:variable name="client_xmi.idref"><xsl:value-of select="@xmi.idref" /></xsl:variable>					
						
								<xsl:for-each select="//UML:Interface[@xmi.id=$client_xmi.idref]">
								<xsl:element name="owl:Class">
									<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
								</xsl:element>
								</xsl:for-each>
								
							</xsl:for-each>									
					</xsl:for-each>
	
			</xsl:element>		
		</xsl:element>	
	<!-- end of rdfs:domain -->
	</xsl:element>
	
	<xsl:element name="rdfs:range">
		<xsl:element name="owl:Class">
			<xsl:element name="owl:unionOf">
				<xsl:attribute name="rdf:parseType">Collection</xsl:attribute>


					<!-- get every class which participate at a dependency -->
					<xsl:for-each select="//UML:Class/UML:ModelElement.clientDependency/UML:Dependency">
						<xsl:variable name="dependency_xmi.idref"><xsl:value-of select="@xmi.idref" /></xsl:variable>
						
							<xsl:for-each select="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:Dependency.supplier/UML:Class">							
								<xsl:variable name="supplier_xmi.idref"><xsl:value-of select="@xmi.idref" /></xsl:variable>					
						
								<xsl:for-each select="//UML:Class[@xmi.id=$supplier_xmi.idref]">
								<xsl:element name="owl:Class">
									<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
								</xsl:element>
								</xsl:for-each>
								
							</xsl:for-each>		
							<xsl:for-each select="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:Dependency.supplier/UML:Interface">							
								<xsl:variable name="supplier_xmi.idref"><xsl:value-of select="@xmi.idref" /></xsl:variable>					
						
								<xsl:for-each select="//UML:Interface[@xmi.id=$supplier_xmi.idref]">
								<xsl:element name="owl:Class">
									<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
								</xsl:element>
								</xsl:for-each>
								
							</xsl:for-each>								
					</xsl:for-each>
	
			</xsl:element>		
		</xsl:element>	
	<!-- end of rdfs:range -->
	</xsl:element>

</xsl:element>

		
<!-- search for every stereotype which was added while modelling - does not to be used actually and only do it once for every stereotype -->
<xsl:for-each select="//UML:Stereotype[generate-id()=generate-id(key('key_stereotype_name', @name)[1])]">

	<!-- sort dependencies (stereotype names) descending due to their names -->
	<xsl:sort select="@name" order="descending" />		

	<xsl:variable name="stereotype_xmi.idref"><xsl:value-of select="@xmi.id" /></xsl:variable>

	<!-- only add it, if stereotype is actually used -->
	<xsl:if test="count(//UML:Dependency/UML:ModelElement.stereotype/UML:Stereotype[@xmi.idref=$stereotype_xmi.idref]) >= 1"> 

	<xsl:element name="owl:ObjectProperty">
		<xsl:attribute name="rdf:ID"><xsl:value-of select="//UML:Stereotype[@xmi.id=$stereotype_xmi.idref]/@name"/></xsl:attribute>
		<xsl:element name="rdfs:subPropertyOf">
			<xsl:attribute name="rdf:resource">#Dependency</xsl:attribute>
		</xsl:element>
			
			
			<xsl:element name="rdfs:domain">
				<xsl:element name="owl:Class">
					<xsl:element name="owl:unionOf">
					<xsl:attribute name="rdf:parseType">Collection</xsl:attribute>


					<!-- get every class which participate at a this particular dependency-->
					<xsl:for-each select="//UML:Class/UML:ModelElement.clientDependency/UML:Dependency">
						<xsl:variable name="dependency_xmi.idref"><xsl:value-of select="@xmi.idref" /></xsl:variable>
						
						<xsl:if test="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:ModelElement.stereotype/UML:Stereotype/@xmi.idref=$stereotype_xmi.idref">
						
							<xsl:for-each select="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:Dependency.client/UML:Class">							
								<xsl:variable name="client_xmi.idref"><xsl:value-of select="@xmi.idref" /></xsl:variable>					
						
								<xsl:for-each select="//UML:Class[@xmi.id=$client_xmi.idref]">
								<xsl:element name="owl:Class">
									<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
								</xsl:element>
								</xsl:for-each>
								
							</xsl:for-each>	

							<xsl:for-each select="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:Dependency.client/UML:Interface">							
								<xsl:variable name="client_xmi.idref"><xsl:value-of select="@xmi.idref" /></xsl:variable>					
						
								<xsl:for-each select="//UML:Interface[@xmi.id=$client_xmi.idref]">
								<xsl:element name="owl:Class">
									<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
								</xsl:element>
								</xsl:for-each>
								
							</xsl:for-each>	
							</xsl:if>								
					</xsl:for-each>
	
				</xsl:element>		
			</xsl:element>	
		<!-- end of rdfs:domain -->
		</xsl:element>
			
			
			<xsl:element name="rdfs:range">
				<xsl:element name="owl:Class">
					<xsl:element name="owl:unionOf">
					<xsl:attribute name="rdf:parseType">Collection</xsl:attribute>


					<!-- get every class which participate at a dependency -->
					<xsl:for-each select="//UML:Class/UML:ModelElement.clientDependency/UML:Dependency">
						<xsl:variable name="dependency_xmi.idref"><xsl:value-of select="@xmi.idref" /></xsl:variable>
						
						<xsl:if test="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:ModelElement.stereotype/UML:Stereotype/@xmi.idref=$stereotype_xmi.idref">
						
							<xsl:for-each select="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:Dependency.supplier/UML:Class">							
								<xsl:variable name="supplier_xmi.idref"><xsl:value-of select="@xmi.idref" /></xsl:variable>					
						
								<xsl:for-each select="//UML:Class[@xmi.id=$supplier_xmi.idref]">
								<xsl:element name="owl:Class">
									<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
								</xsl:element>
								</xsl:for-each>
								
							</xsl:for-each>
							<xsl:for-each select="//UML:Dependency[@xmi.id=$dependency_xmi.idref]/UML:Dependency.supplier/UML:Interface">							
								<xsl:variable name="supplier_xmi.idref"><xsl:value-of select="@xmi.idref" /></xsl:variable>					
						
								<xsl:for-each select="//UML:Interface[@xmi.id=$supplier_xmi.idref]">
								<xsl:element name="owl:Class">
									<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
								</xsl:element>
								</xsl:for-each>
								
							</xsl:for-each>
					        </xsl:if>									
					</xsl:for-each>
	
					</xsl:element>		
				</xsl:element>	
			</xsl:element>			
		
	<!-- end of owl:ObjectProperty -->	
	</xsl:element>

 </xsl:if>
	
</xsl:for-each>

</xsl:when>








</xsl:choose>	
	
	
<!-- ############################-->
<!-- Handle ObjectProperties, which have an association name  -->
<!-- ########################### -->    	
	
		<!-- only write those associations that differ in their names because of First Class Concept -->
		<xsl:for-each select="//UML:Association[generate-id(.)=generate-id(key('key_association_name', @name)[1])]">
                <!--<xsl:for-each select="//UML:Association">-->
		
			<!-- sort association descending due to their names -->
			<xsl:sort select="@name" order="descending" />			
			
			<!-- save current association name in variable -->
			<!--<xsl:variable name="association_name_of_key" select="@name" />-->

			<xsl:call-template name="op_aggregation_or_named">
				<xsl:with-param name="association_xmi.id"><xsl:value-of select="@xmi.id" /></xsl:with-param>
			</xsl:call-template>
						
		<!-- end of every association with same name -->
		</xsl:for-each>		
        
<!-- close ontology -->       
</rdf:RDF>  

<xsl:message>


XMI document successfully transformed to an OWL DL ontology!
</xsl:message>
  
<!-- End of whole template -->
</xsl:template>



<!-- ###################### -->
<!-- Template to add ObjectPropertys for AssociationsClass which have classes that are in a relation trough a associationClass as range -->
<!-- ######################## -->
<xsl:template name="add_associationClass_op">
 <xsl:param name="associationClass_name" />
 <xsl:param name="firstClass_xmi.idref" />
 <xsl:param name="secondClass_xmi.idref" />
 
 <xsl:variable name="firstClass_name"><xsl:value-of select="//UML:Class[@xmi.id=$firstClass_xmi.idref]/@name" /></xsl:variable>
 <xsl:variable name="secondClass_name"><xsl:value-of select="//UML:Class[@xmi.id=$secondClass_xmi.idref]/@name" /></xsl:variable>
 
 <xsl:element name="owl:ObjectProperty">
	 <xsl:attribute name="rdf:ID">firstOf_<xsl:value-of select="$firstClass_name" />_<xsl:value-of select="$secondClass_name" /></xsl:attribute>
		 <xsl:element name="rdfs:domain">
			 <xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$associationClass_name" /></xsl:attribute>
		 </xsl:element> 
		 <xsl:element name="rdfs:range">
			 <xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$firstClass_name" /></xsl:attribute>
		</xsl:element>
 </xsl:element>
 
  <xsl:element name="owl:ObjectProperty">
	 <xsl:attribute name="rdf:ID">secondOf_<xsl:value-of select="$firstClass_name" />_<xsl:value-of select="$secondClass_name" /></xsl:attribute>
		 <xsl:element name="rdfs:domain">
			 <xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$associationClass_name" /></xsl:attribute>
		</xsl:element>
		 <xsl:element name="rdfs:range">
			 <xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$secondClass_name" /></xsl:attribute>
		</xsl:element>
 </xsl:element>

</xsl:template>


<xsl:template name="createAssociationClassEndPropertyRestriction">
<xsl:param name="firstClass_xmi.idref" />
<xsl:param name="secondClass_xmi.idref" />

 <xsl:variable name="firstClass_name"><xsl:value-of select="//UML:Class[@xmi.id=$firstClass_xmi.idref]/@name" /></xsl:variable>
 <xsl:variable name="secondClass_name"><xsl:value-of select="//UML:Class[@xmi.id=$secondClass_xmi.idref]/@name" /></xsl:variable>
 
     <xsl:element name="rdfs:subClassOf">
		<xsl:element name="owl:Restriction">
			<xsl:element name="owl:onProperty">
			
				<xsl:attribute name="rdf:resource">#firstOf_<xsl:value-of select="$firstClass_name" />_<xsl:value-of select="$secondClass_name" /></xsl:attribute>
				
			</xsl:element>		
			
			<!-- add multiplicity -->
			<xsl:call-template name="add_multiplicity_op">
				<xsl:with-param name="lower">1</xsl:with-param>
				<xsl:with-param name="upper">1</xsl:with-param>			
			</xsl:call-template>
			
		</xsl:element>	
	</xsl:element>

      <xsl:element name="rdfs:subClassOf">
		<xsl:element name="owl:Restriction">
			<xsl:element name="owl:onProperty">
			
				<xsl:attribute name="rdf:resource">#secondOf_<xsl:value-of select="$firstClass_name" />_<xsl:value-of select="$secondClass_name" /></xsl:attribute>
				
			</xsl:element>		
			
			<!-- add multiplicity -->
			<xsl:call-template name="add_multiplicity_op">
				<xsl:with-param name="lower">1</xsl:with-param>
				<xsl:with-param name="upper">1</xsl:with-param>			
			</xsl:call-template>
			
		</xsl:element>	
	</xsl:element>

</xsl:template>


<!-- ###################### -->
<!-- add_dependencies_toClass -->
<!-- ######################## -->

<xsl:template name="add_dependencies_toClass">
	<xsl:param name="dependency_xmi.idref" />
	<xsl:param name="class_name" />
	<xsl:param name="class_id" />
	<xsl:param name="stereotype_xmi.idref" />
	<xsl:param name="client_class_xmi.idref" />
	<xsl:param name="supplier_class_xmi.idref" />
	<xsl:param name="supplier_interface_xmi.idref" />

	<!-- check if a stereotype is given -->
	<xsl:choose>
		<xsl:when test="($stereotype_xmi.idref='')">
		
			<xsl:element name="rdfs:subClassOf">
				<xsl:element name="owl:Restriction">
					<xsl:element name="owl:onProperty">
						<xsl:attribute name="rdf:resource">#Dependency</xsl:attribute>
					</xsl:element>
					<xsl:element name="owl:cardinality"><xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:attribute>1</xsl:element>
					<xsl:for-each select="//UML:Class[@xmi.id=$supplier_class_xmi.idref]">			
                                          <xsl:element name="owl:onClass">					
				             <xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name"/>:<xsl:value-of select="@name" /></xsl:attribute>
					  </xsl:element>
                                        </xsl:for-each>
					<xsl:for-each select="//UML:Interface[@xmi.id=$supplier_interface_xmi.idref]">			
                                          <xsl:element name="owl:onClass">					
				             <xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name"/>:<xsl:value-of select="@name" /></xsl:attribute>
					  </xsl:element>
                                        </xsl:for-each>
				</xsl:element>
			</xsl:element>
		
		</xsl:when>
	
	
	<!-- otherwise there is a stereotype given -->
	<xsl:otherwise>
	
			<xsl:element name="rdfs:subClassOf">
				<xsl:element name="owl:Restriction">
					<xsl:element name="owl:onProperty">
						<xsl:attribute name="rdf:resource">#<xsl:value-of select="//UML:Stereotype[@xmi.id=$stereotype_xmi.idref]/@name" /></xsl:attribute>
					</xsl:element>
					<xsl:element name="owl:cardinality"><xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:attribute>1</xsl:element>
					<xsl:for-each select="//UML:Class[@xmi.id=$supplier_class_xmi.idref]">			
                                          <xsl:element name="owl:onClass">					
				             <xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name"/>:<xsl:value-of select="@name" /></xsl:attribute>
					  </xsl:element>
                                        </xsl:for-each>
					<xsl:for-each select="//UML:Interface[@xmi.id=$supplier_interface_xmi.idref]">			
                                          <xsl:element name="owl:onClass">					
				             <xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name"/>:<xsl:value-of select="@name" /></xsl:attribute>
					  </xsl:element>
                                        </xsl:for-each>
				</xsl:element>
			</xsl:element>
	
	</xsl:otherwise>
	</xsl:choose>
			
</xsl:template>





<!-- ###################### -->
<!-- op_aggregation_or_named -->
<!-- ######################## -->

<xsl:template name="op_aggregation_or_named">
<xsl:param name="association_xmi.id"/>

  <xsl:variable name="association_name_of_key"><xsl:value-of select="//UML:Association[@xmi.id=$association_xmi.id]/@name"/></xsl:variable>

  <!--<xsl:if test="not($association_name_of_key='') or //UML:Association[@xmi.id=$association_xmi.id]/UML:Association.connection/UML:AssociationEnd[1]/@aggregation='composite' or //UML:Association[@xmi.id=$association_xmi.id]/UML:Association.connection/UML:AssociationEnd[1]/@aggregation='aggregate'">-->

  <xsl:if test="not($association_name_of_key='') ">
		
			<!--create owl:ObjectProperty -->
			<xsl:element name="owl:ObjectProperty">
			
			<!--create attribute with property name -->

                                <!--<xsl:choose> -->
                                <!--  <xsl:when test="not($association_name_of_key='')"> -->
                                    <xsl:attribute name="rdf:ID">inverseOf_<xsl:value-of select="$association_name_of_key"/></xsl:attribute>
                                <!--  </xsl:when> -->
                                <!--  <xsl:otherwise> -->
                                <!--    <xsl:attribute name="rdf:ID">inverseOf_<xsl:call-template name="getPropertyId"><xsl:with-param name="association_xmi.id"><xsl:value-of select="$association_xmi.id"/></xsl:with-param></xsl:call-template></xsl:attribute> -->
                                <!--  </xsl:otherwise> -->
                                <!--</xsl:choose> -->
				
				<xsl:choose>
					
						<!-- if there is more than one class participating at this domain then create unionOf -->
						<xsl:when test="count(//UML:Association[@xmi.id=$association_xmi.id])>1">					
						
					<xsl:if test="//UML:Association[@xmi.id=$association_xmi.id]/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate'] or //UML:Association[@xmi.id=$association_xmi.id]/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite'] ">
						<xsl:element name="rdfs:subPropertyOf">
							<xsl:attribute name="rdf:resource">#is_part_of</xsl:attribute>						
						</xsl:element>
					</xsl:if>		

							<!-- create domain element -->
							<xsl:element name="rdfs:range">				
								<!-- create class element -->
								<xsl:element name="owl:Class">				
									<!-- create unionOf element -->
									<xsl:element name="owl:unionOf">				
										<!-- create parseType attribute with value Collection -->
										<xsl:attribute name="rdf:parseType">Collection</xsl:attribute>				
												
										<!-- search for every association which has same name. Has to be done with for-each because there could be more associations with same name used by different classes -->
										<xsl:for-each select="//UML:Association[@xmi.id=$association_xmi.id]">										

											<!-- search for classes which participate in domain -->
											<xsl:for-each select="//UML:Class[@xmi.id=(current()/UML:Association.connection/UML:AssociationEnd[position()=1]/UML:AssociationEnd.participant/UML:Class/@xmi.idref)]">							
												<!-- write class element -->
												<xsl:element name="owl:Class">					
													<!-- and add class name to collection -->
													<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"></xsl:value-of></xsl:attribute>					
												</xsl:element>
											<!-- end of search for class -->
											</xsl:for-each>	
											
											
											<!-- search for AssociationClasses which participate in domain -->
											<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=(current()/UML:Association.connection/UML:AssociationEnd[position()=1]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref)]">							
												<!-- write class element -->
												<xsl:element name="owl:Class">					
													<!-- and add class name to collection -->
													<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"></xsl:value-of></xsl:attribute>					
												</xsl:element>
											<!-- end of search for class -->
											</xsl:for-each>	
											
										<!-- end of search for every association -->
										</xsl:for-each>		
						
									<!-- end UnionOf -->
									</xsl:element>					
								<!-- end class element -->
								</xsl:element>												
							<!-- end domain element -->
							</xsl:element>	
						
						</xsl:when>
						
					<!-- otherwise there is only one class as domain -->	
					<xsl:otherwise>
					
						<xsl:if test="//UML:Association[@xmi.id=$association_xmi.id]/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate'] or //UML:Association[@xmi.id=$association_xmi.id]/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite'] ">
						<xsl:element name="rdfs:subPropertyOf">
							<xsl:attribute name="rdf:resource">#is_part_of</xsl:attribute>						
						</xsl:element>
					</xsl:if>
						
							<!-- create domain element -->
							<xsl:element name="rdfs:range">							
								<!-- and add class name - again quite cumbersome, I know  -->
								<xsl:for-each select="//UML:Class[@xmi.id=(current()/UML:Association.connection/UML:AssociationEnd[position()=1]/UML:AssociationEnd.participant/UML:Class/@xmi.idref)]">
								<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" />
								</xsl:attribute>
								</xsl:for-each>
								<!-- and add class name from associationClass - again quite cumbersome, I know  -->
								<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=(current()/UML:Association.connection/UML:AssociationEnd[position()=1]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref)]">
								<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" />
								</xsl:attribute>
								</xsl:for-each>
							<!-- end domain element -->
							</xsl:element>								
						</xsl:otherwise>		
										
				</xsl:choose>

				<xsl:choose>
				
				
					<!-- if a specific association exists more than once create unionOf range -->
					<xsl:when test="count(//UML:Association[@xmi.id=$association_xmi.id])>1">	
					
						<!-- create range of property -->
						<xsl:element name="rdfs:domain">					
							<!-- create class element -->
							<xsl:element name="owl:Class">				
								<!-- create unionOf element -->
								<xsl:element name="owl:unionOf">				
									<!-- create parseType attribute with value Collection -->
									<xsl:attribute name="rdf:parseType">Collection</xsl:attribute>		
			

										<!-- search for every association which has same name -->
										<xsl:for-each select="//UML:Association[@xmi.id=$association_xmi.id]">										

						<!-- call template to decide whether it is a class or an interface -->
						<xsl:call-template name="decide_class_or_interface_unionOf">
							<xsl:with-param name="xmi.idref_of_range_class"><xsl:value-of select="current()/UML:Association.connection/UML:AssociationEnd[position() =2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" /></xsl:with-param>
							<xsl:with-param name="xmi.idref_of_range_interface"><xsl:value-of select="current()/UML:Association.connection/UML:AssociationEnd[position() =2]/UML:AssociationEnd.participant/UML:Interface/@xmi.idref" />
							</xsl:with-param>
						</xsl:call-template>			

											
										</xsl:for-each>	
										
									<!-- end UnionOf -->
									</xsl:element>					
								<!-- end class element -->
								</xsl:element>					
							<!-- end of rdfs:range -->					
							</xsl:element>					

						</xsl:when>
				
					<!-- otherwise there is only one class as domain -->	
					<xsl:otherwise>
						
						<!-- get class that participate in this association as domain-->
						<xsl:variable name="xmi.idref_of_range_class" select="current()/UML:Association.connection/UML:AssociationEnd[position() =2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" />
						
						<!-- get AssociationClass that participate in this association as domain -->
						<xsl:variable name="xmi.idref_of_range_AC" select="current()/UML:Association.connection/UML:AssociationEnd[position() =2]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" />
						
						<!-- eventually: instead of a class an interface can be the range. save this idref -->
						<xsl:variable name="xmi.idref_of_range_interface" select="current()/UML:Association.connection/UML:AssociationEnd[position() =2]/UML:AssociationEnd.participant/UML:Interface/@xmi.idref" />
						

						<!-- call template to decide whether it is a class or an interface -->
						<xsl:call-template name="decide_class_or_interface_single">
							<xsl:with-param name="xmi.idref_of_range_class"><xsl:value-of select="$xmi.idref_of_range_class" /></xsl:with-param>
							<xsl:with-param name="xmi.idref_of_range_AC"><xsl:value-of select="$xmi.idref_of_range_AC" /></xsl:with-param>
							<xsl:with-param name="xmi.idref_of_range_interface"><xsl:value-of select="$xmi.idref_of_range_interface" /></xsl:with-param>
							<xsl:with-param name="domain">false</xsl:with-param>
						</xsl:call-template>		
													
					</xsl:otherwise>		
										
				</xsl:choose>
				
				
				<xsl:element name="owl:inverseOf">
					
                                  <!--<xsl:choose>-->
                                  <!--  <xsl:when test="not($association_name_of_key='')">-->
                                          <xsl:attribute name="rdf:resource">#<xsl:value-of select="$association_name_of_key"/></xsl:attribute>
                                  <!--  </xsl:when>-->
                                  <!--  <xsl:otherwise>-->
                                  <!--    <xsl:attribute name="rdf:resource">#<xsl:call-template name="getPropertyId"><xsl:with-param name="association_xmi.id"><xsl:value-of select="$association_xmi.id"/></xsl:with-param></xsl:call-template></xsl:attribute>-->
                                  <!--  </xsl:otherwise>-->
                                  <!--</xsl:choose>-->

				</xsl:element>
						
			<!-- end of owl:ObjectProperty -->
			</xsl:element>		
			
			
			
			<!-- ################### -->
			<!--add inverseOf_  -->
			<!-- ################### -->
			
			<!-- add inverseOf Property using inverseOf_ prefix, switch domain and range -->
			<xsl:element name="owl:ObjectProperty">

                                <!--<xsl:choose>-->
                                <!--  <xsl:when test="not($association_name_of_key='')">-->
                                    <xsl:attribute name="rdf:ID"><xsl:value-of select="$association_name_of_key"/></xsl:attribute>
                                <!--  </xsl:when>-->
                                <!--  <xsl:otherwise>-->
                                <!--    <xsl:attribute name="rdf:ID"><xsl:call-template name="getPropertyId"><xsl:with-param name="association_xmi.id"><xsl:value-of select="$association_xmi.id"/></xsl:with-param></xsl:call-template></xsl:attribute>-->
                                <!--  </xsl:otherwise>-->
                                <!--</xsl:choose>-->
				
				
				<xsl:choose>
				
				
				<!-- if a specific association exists more than once create unionOf range -->
				<xsl:when test="count(//UML:Association[@xmi.id=$association_xmi.id])>1">
				
					<xsl:if test="//UML:Association[@xmi.id=$association_xmi.id]/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate'] or //UML:Association[@xmi.id=$association_xmi.id]/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite'] ">
						<xsl:element name="rdfs:subPropertyOf">
							<xsl:attribute name="rdf:resource">#consists_of</xsl:attribute>						
						</xsl:element>
					</xsl:if>	
					
				<!-- create domain of property -->
				<xsl:element name="rdfs:range">		
				
				<!-- create class element -->
				<xsl:element name="owl:Class">				
					<!-- create unionOf element -->
					<xsl:element name="owl:unionOf">				
							<!-- create parseType attribute with value Collection -->
							<xsl:attribute name="rdf:parseType">Collection</xsl:attribute>					
					
					<!-- search for every association which has same name -->
					<xsl:for-each select="//UML:Association[@xmi.id=$association_xmi.id]">
										
						<!-- get class that participate in this association as range -->
						<xsl:variable name="xmi.idref_of_range_class" select="current()/UML:Association.connection/UML:AssociationEnd[position() =2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" />
											
						<!-- eventually: instead of a class an interface can be the range. save this idref -->
						<xsl:variable name="xmi.idref_of_range_interface" select="current()/UML:Association.connection/UML:AssociationEnd[position() =2]/UML:AssociationEnd.participant/UML:Interface/@xmi.idref" />
						
						<!-- call template to decide whether it is a class or an interface -->
						<xsl:call-template name="decide_class_or_interface_unionOf">
							<xsl:with-param name="xmi.idref_of_range_class"><xsl:value-of select="$xmi.idref_of_range_class" /></xsl:with-param>							
							<xsl:with-param name="xmi.idref_of_range_interface"><xsl:value-of select="$xmi.idref_of_range_interface" /></xsl:with-param>
						</xsl:call-template>					
			
										
					</xsl:for-each>	
								
					<!-- end UnionOf -->
					</xsl:element>					
				<!-- end class element -->
				</xsl:element>						
				<!-- end of rdfs:domain -->					
				</xsl:element>			
				
			</xsl:when>
				
					<!-- otherwise there is only one class as domain -->	
					<xsl:otherwise>
					
					<xsl:if test="//UML:Association[@xmi.id=$association_xmi.id]/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate'] or //UML:Association[@xmi.id=$association_xmi.id]/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite'] ">
						<xsl:element name="rdfs:subPropertyOf">
							<xsl:attribute name="rdf:resource">#consists_of</xsl:attribute>						
						</xsl:element>
					</xsl:if>	
						
						<!-- get class that participate in this association as domain-->
						<xsl:variable name="xmi.idref_of_range_class" select="current()/UML:Association.connection/UML:AssociationEnd[position() =2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" />
						
						<!-- get associationClass that participate in this association as domain -->
						<xsl:variable name="xmi.idref_of_range_AC" select="//UML:Association[@xmi.id=$association_xmi.id]/UML:Association.connection/UML:AssociationEnd[position() =2]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" />
						
						<!-- eventually: instead of a class an interface can be the range. save this idref -->
						<xsl:variable name="xmi.idref_of_range_interface" select="current()/UML:Association.connection/UML:AssociationEnd[position() =2]/UML:AssociationEnd.participant/UML:Interface/@xmi.idref" />


						<!-- call template to decide whether it is a class or an interface -->
						<xsl:call-template name="decide_class_or_interface_single">
							<xsl:with-param name="xmi.idref_of_range_class"><xsl:value-of select="$xmi.idref_of_range_class" /></xsl:with-param>
							<xsl:with-param name="xmi.idref_of_range_AC"><xsl:value-of select="$xmi.idref_of_range_AC" /></xsl:with-param>
							<xsl:with-param name="xmi.idref_of_range_interface"><xsl:value-of select="$xmi.idref_of_range_interface" /></xsl:with-param>
							<xsl:with-param name="domain">true</xsl:with-param>
						</xsl:call-template>	
													
					</xsl:otherwise>		
										
				</xsl:choose>
				
				<xsl:choose>
				
			<!-- if there is more than one class participating at this range then create unionOf -->
			<xsl:when test="count(//UML:Association[@xmi.id=$association_xmi.id])>1">		
				
				
			<!-- create range element -->
			<xsl:element name="rdfs:domain">				
				<!-- create class element -->
				<xsl:element name="owl:Class">				
					<!-- create unionOf element -->
					<xsl:element name="owl:unionOf">				
							<!-- create parseType attribute with value Collection -->
							<xsl:attribute name="rdf:parseType">Collection</xsl:attribute>					
					
					<!-- search for every association which has same name -->
					<xsl:for-each select="//UML:Association[@xmi.id=$association_xmi.id]">	
									
						<!-- get class that participate in this association as domain -->
						<xsl:variable name="xmi.idref_of_domain_class" select="current()/UML:Association.connection/UML:AssociationEnd[position()=1]/UML:AssociationEnd.participant/UML:Class/@xmi.idref" />
						
							<!-- search this specific class -->
							<xsl:for-each select="//UML:Class[@xmi.id=$xmi.idref_of_domain_class]">
							
								<!-- write class element -->
								<xsl:element name="owl:Class">
					
									<!-- and add class name to collection -->
									<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"></xsl:value-of></xsl:attribute>
					
								</xsl:element>
							<!-- end of search for class -->
							</xsl:for-each>		
							

						<!-- get class that participate in this association as domain -->
						<xsl:variable name="xmi.idref_of_domain_AC" select="current()/UML:Association.connection/UML:AssociationEnd[position()=1]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref" />
						
							<!-- search this specific class -->
							<xsl:for-each select="//UML:AssociationClass[@xmi.id=$xmi.idref_of_domain_AC]">
							
								<!-- write class element -->
								<xsl:element name="owl:Class">
					
									<!-- and add class name to collection -->
									<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"></xsl:value-of></xsl:attribute>
					
								</xsl:element>
							<!-- end of search for class -->
							</xsl:for-each>				
							
							
									
					<!-- end of search for every association -->					
					</xsl:for-each>	
								
					<!-- end UnionOf -->
					</xsl:element>					
				<!-- end class element -->
				</xsl:element>												
	    	<!-- end range element -->
		    </xsl:element>
		    
			<xsl:element name="owl:inverseOf">

                          <!--<xsl:choose>-->
                          <!--  <xsl:when test="not($association_name_of_key='')">-->
                              <xsl:attribute name="rdf:resource">#inverseOf_<xsl:value-of select="$association_name_of_key"/></xsl:attribute>
                          <!--  </xsl:when>-->
                          <!--  <xsl:otherwise>-->
                          <!--    <xsl:attribute name="rdf:resource">#inverseOf_<xsl:call-template name="getPropertyId"><xsl:with-param name="association_xmi.id"><xsl:value-of select="$association_xmi.id"/></xsl:with-param></xsl:call-template></xsl:attribute>-->
                          <!-- </xsl:otherwise>-->
                          <!--</xsl:choose>-->

			</xsl:element>
					
			</xsl:when>	
			
			<!-- otherwise there is only one class as range -->	
					<xsl:otherwise>
						
							<xsl:for-each select="//UML:Class[@xmi.id=(current()/UML:Association.connection/UML:AssociationEnd[position()=1]/UML:AssociationEnd.participant/UML:Class/@xmi.idref)]">
							<!-- create domain element -->
							<xsl:element name="rdfs:domain">
								<!-- and add class name - again quite cumbersome, I know  -->
								<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name">
									</xsl:value-of>
								</xsl:attribute>
							<!-- end domain element -->
							</xsl:element>	
							</xsl:for-each>

							<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=(current()/UML:Association.connection/UML:AssociationEnd[position()=1]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref)]">
							<!-- create domain element -->
							<xsl:element name="rdfs:domain">
								<!-- and add class name - again quite cumbersome, I know  -->
								<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name">
									</xsl:value-of>
								</xsl:attribute>
							<!-- end domain element -->
							</xsl:element>	
							</xsl:for-each>
							
			<xsl:element name="owl:inverseOf">

                          <!--<xsl:choose>-->
                          <!--  <xsl:when test="not($association_name_of_key='')">-->
                              <xsl:attribute name="rdf:resource">#inverseOf_<xsl:value-of select="$association_name_of_key"/></xsl:attribute>
                          <!--  </xsl:when>-->
                          <!--  <xsl:otherwise>-->
                          <!--    <xsl:attribute name="rdf:resource">#inverseOf_<xsl:call-template name="getPropertyId"><xsl:with-param name="association_xmi.id"><xsl:value-of select="$association_xmi.id"/></xsl:with-param></xsl:call-template></xsl:attribute>-->
                          <!--  </xsl:otherwise>-->
                          <!--</xsl:choose>-->

			</xsl:element>							
			
						</xsl:otherwise>		
										
				</xsl:choose>
				
		</xsl:element>
	
			
  </xsl:if>

</xsl:template>




<!-- ############################# -->
<!-- template for deciding if class or interface when adding single range or domain-->
<!-- ############################# -->	

<xsl:template name="decide_class_or_interface_single">
<xsl:param name="xmi.idref_of_range_class"/>
<xsl:param name="xmi.idref_of_range_AC"/>
<xsl:param name="xmi.idref_of_range_interface"/>
<xsl:param name="domain" />


<xsl:choose>


	<!-- range is a class -->
	<xsl:when test="not($xmi.idref_of_range_class='') and ($domain='true') ">

							<!-- search this specific class -->
							<xsl:for-each select="//UML:Class[@xmi.id=$xmi.idref_of_range_class]">
							
								<!-- write class element -->
								<xsl:element name="rdfs:range">
					
									<!-- and add class name to collection -->
									<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"></xsl:value-of></xsl:attribute>
					
								</xsl:element>
							<!-- end of search for class -->
							</xsl:for-each>
							
								
	</xsl:when>

	<xsl:when test="not($xmi.idref_of_range_AC='') and ($domain='true') ">

							
							
							<!-- search associationClass and add it as range (kind of weird, but has to be like this)  -->
							<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$xmi.idref_of_range_AC]">
							
								<!-- write class element -->
								<xsl:element name="rdfs:range">
					
									<!-- and add class name to collection -->
									<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"></xsl:value-of></xsl:attribute>
					
								</xsl:element>
							<!-- end of search for class -->
							</xsl:for-each>	
								
	</xsl:when>

	<!-- range is an interface -->
	<xsl:when test="not($xmi.idref_of_range_interface='') and ($domain='true') ">


							<!-- search this specific class -->
							<xsl:for-each select="//UML:Interface[@xmi.id=$xmi.idref_of_range_interface]">
							
								<!-- write class element -->
								<xsl:element name="rdfs:range">
					
									<!-- and add class name to collection -->
									<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
					
								</xsl:element>
							<!-- end of search for class -->
							</xsl:for-each>	
	</xsl:when>
	
<!-- range is a class -->
	<xsl:when test="not($xmi.idref_of_range_class='') and ($domain='false') ">


							<!-- search this specific class -->
							<xsl:for-each select="//UML:Class[@xmi.id=$xmi.idref_of_range_class]">
							
								<!-- write class element -->
								<xsl:element name="rdfs:domain">
					
									<!-- and add class name to collection -->
									<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
					
								</xsl:element>
							<!-- end of search for class -->
							</xsl:for-each>	
	</xsl:when>

	
	
	<xsl:when test="not($xmi.idref_of_range_AC='') and ($domain='false') ">

							
							
							<!-- search associationClass and add it as range (kind of weird, but has to be like this)  -->
							<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$xmi.idref_of_range_AC]">
							
								<!-- write class element -->
								<xsl:element name="rdfs:domain">
					
									<!-- and add class name to collection -->
									<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"></xsl:value-of></xsl:attribute>
					
								</xsl:element>
							<!-- end of search for class -->
							</xsl:for-each>	
								
	</xsl:when>

	<!-- range is an interface -->
	<xsl:when test="not($xmi.idref_of_range_interface='') and ($domain='false') ">


							<!-- search this specific class -->
							<xsl:for-each select="//UML:Interface[@xmi.id=$xmi.idref_of_range_interface]">
							
								<!-- write class element -->
								<xsl:element name="rdfs:domain">
					
									<!-- and add class name to collection -->
									<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
					
								</xsl:element>
							<!-- end of search for class -->
							</xsl:for-each>	
	</xsl:when>

</xsl:choose>							
</xsl:template>


<!-- ############################# -->
<!-- template for deciding if class or interface when adding unionOf construct-->
<!-- ############################# -->	

<xsl:template name="decide_class_or_interface_unionOf">
<xsl:param name="xmi.idref_of_range_class"/>
<xsl:param name="xmi.idref_of_range_interface"/>


<xsl:choose>

	<!-- range is a class -->
	<xsl:when test="not($xmi.idref_of_range_class='')">


							<!-- search this specific class -->
							<xsl:for-each select="//UML:Class[@xmi.id=$xmi.idref_of_range_class]">
							
								<!-- write class element -->
								<xsl:element name="owl:Class">
					
									<!-- and add class name to collection -->
									<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
					
								</xsl:element>
							<!-- end of search for class -->
							</xsl:for-each>								

	</xsl:when>
	
	<!-- range is an interface -->
	<xsl:when test="not($xmi.idref_of_range_interface='')">


							<!-- search this specific class -->
							<xsl:for-each select="//UML:Interface[@xmi.id=$xmi.idref_of_range_interface]">
							
								<!-- write class element -->
								<xsl:element name="owl:Class">
					
									<!-- and add class name to collection -->
									<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name" /></xsl:attribute>
					
								</xsl:element>
							<!-- end of search for class -->
							</xsl:for-each>	
	</xsl:when>

</xsl:choose>							
</xsl:template>





<!-- ############################# -->
<!-- template for deciding if Object or DatatypeProperty to create-->
<!-- ############################# -->	

<xsl:template name="op_or_dp_decision">
<xsl:param name="idref" />
<xsl:param name="class_idref" />
<xsl:param name="AC_idref" />
<xsl:param name="attribute_name_of_key" />


<!-- if there is a class which has stereotype Datatyp then save it -->
<xsl:variable name="class_toCheck_stereotype" select="//UML:Class[@xmi.id=$class_idref]" />
<xsl:variable name="stereotype_idref" select="$class_toCheck_stereotype/UML:ModelElement.stereotype/UML:Stereotype/@xmi.idref" />
<xsl:variable name="stereotype_name" select="//UML:Stereotype[@xmi.id=$stereotype_idref]/@name" />

					<!-- look for class which has given id if it exists -->
					<xsl:variable name="ref_class" select="//UML:Class[@xmi.id=$class_idref]" />			
							
					<!-- then save class name in variable -->
					<xsl:variable name="range_class" select="$ref_class/@name" />
				

<!-- decide wether attribute has DataType or Class as value-->
			<xsl:choose>			
			
				<!-- Datatype as value so idref is not empty or stereotype=DataType or DataType is from java.lang-->
				<xsl:when test="not($idref='') or $stereotype_name='DataType' or $range_class='String' or $range_class='Time' or $range_class='Short' or $range_class='Long' or $range_class='Float' or $range_class='Double' or $range_class='Date' or $range_class='Character' or $range_class='Byte' or $range_class='Boolean' or $range_class='Integer' or $range_class='URL' ">

					<!--create owl:DatatypeProperty -->
					<xsl:element name="owl:DatatypeProperty">
			
					<!--create attribute with property name -->
					<xsl:attribute name="rdf:ID">
						<xsl:value-of select="@name" />
					</xsl:attribute>
					
					<!-- create domain element -->
					<xsl:element name="rdfs:domain">
				
						<!-- create class element -->
						<xsl:element name="owl:Class">
				
							<!-- create unionOf element -->
							<xsl:element name="owl:unionOf">
				
								<!-- create parseType attribute with value Collection -->
								<xsl:attribute name="rdf:parseType">Collection</xsl:attribute>
										
									<!-- search for every class that has current attribute to add to the collection -->
									<xsl:for-each select="//UML:Class">					
										<!-- if current attribute name is equal to one of the current class -->
										<xsl:if test="UML:Classifier.feature/UML:Attribute/@name=$attribute_name_of_key">					
											<!-- write class element -->
											<xsl:element name="owl:Class">					
												<!-- and add class name as attribute to collection -->
												<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"></xsl:value-of></xsl:attribute>					
											</xsl:element>					
										</xsl:if>					
									</xsl:for-each>
									<!-- same for associationClasses -->
									<!-- search for every associationClass that has current attribute to add to the collection -->
									<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass">					
										<!-- if current attribute name is equal to one of the current class -->
										<xsl:if test="UML:Classifier.feature/UML:Attribute/@name=$attribute_name_of_key">					
											<!-- write class element -->
											<xsl:element name="owl:Class">					
												<!-- and add class name as attribute to collection -->
												<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"></xsl:value-of></xsl:attribute>					
											</xsl:element>					
										</xsl:if>					
									</xsl:for-each>
				
							<!-- end UnionOf -->
							</xsl:element>
					
						<!-- end class element -->
						</xsl:element>
												
					<!-- end domain element -->
					</xsl:element>
				
				<!-- create range of property -->
				<xsl:element name="rdfs:range">		
				
					<xsl:attribute name="rdf:resource">
					
					<!-- choose, if range is an int or string or binary and so on and write correct URI as resource -->
					<xsl:choose>		
					
						<!-- if range is not a normal datatype but a class with stereotype dataype then add this class as range -->
						<xsl:when test="$stereotype_name='DataType' or $range_class='String' or $range_class='Time' or $range_class='Short' or $range_class='Long' or $range_class='Float' or $range_class='Double' or $range_class='Date' or $range_class='Character' or $range_class='Byte' or $range_class='Boolean' or $range_class='Integer' or $range_class='URL' ">
						
						<xsl:for-each select="//UML:Class[@xmi.id=$class_idref]">
						<xsl:variable name="name"><xsl:value-of select="@name" /></xsl:variable>
						
						<xsl:choose>
						
		
						<xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='int'">http://www.w3.org/2001/XMLSchema#int</xsl:when>
						<xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='integer'">http://www.w3.org/2001/XMLSchema#integer</xsl:when>
						<xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='boolean'">http://www.w3.org/2001/XMLSchema#boolean</xsl:when>
						<xsl:when test="'real'=translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz') or
                            'number'=translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')or 
                            'double'=translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')">http://www.w3.org/2001/XMLSchema#double</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='float'">http://www.w3.org/2001/XMLSchema#float</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='binary'">http://www.w3.org/2001/XMLSchema#hexBinaray</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='string'">http://www.w3.org/2001/XMLSchema#string</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='char'">http://www.w3.org/2001/XMLSchema#string</xsl:when>                        
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='character'">http://www.w3.org/2001/XMLSchema#string</xsl:when>                        
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='time'">http://www.w3.org/2001/XMLSchema#time</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='datetime'">http://www.w3.org/2001/XMLSchema#datetime</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='date'">http://www.w3.org/2001/XMLSchema#date</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='short'">http://www.w3.org/2001/XMLSchema#short</xsl:when>                        
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='normalizedstring'">http://www.w3.org/2001/XMLSchema#normalizedString</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='nonnegativeinteger'">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='positiveinteger'">http://www.w3.org/2001/XMLSchema#positiveInteger</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='nonpositiveinteger'">http://www.w3.org/2001/XMLSchema#nonPositiveInteger</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='negativeinteger'">http://www.w3.org/2001/XMLSchema#negativeInteger</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='long'">http://www.w3.org/2001/XMLSchema#long</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='byte'">http://www.w3.org/2001/XMLSchema#byte</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='unsignedlong'">http://www.w3.org/2001/XMLSchema#unsignedLong</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='unsignedint'">http://www.w3.org/2001/XMLSchema#unsignedInt</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='unsignedshort'">http://www.w3.org/2001/XMLSchema#unsignedShort</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='unsignedbyte'">http://www.w3.org/2001/XMLSchema#unsignedByte</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='heybinary'">http://www.w3.org/2001/XMLSchema#hexBinary</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ64','abcdefghijklmnopqrstuvwxyz64')='base64binary'">http://www.w3.org/2001/XMLSchema#bas64Binary</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='gyearmonth'">http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='gyear'">http://www.w3.org/2001/XMLSchema#gYear</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='gmonthday'">http://www.w3.org/2001/XMLSchema#gMonthDay</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='gday'">http://www.w3.org/2001/XMLSchema#gDay</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='gmonth'">http://www.w3.org/2001/XMLSchema#gMonth</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='anyuri'">http://www.w3.org/2001/XMLSchema#anyURI</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='url'">http://www.w3.org/2001/XMLSchema#anyURI</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='uri'">http://www.w3.org/2001/XMLSchema#anyURI</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='token'">http://www.w3.org/2001/XMLSchema#token</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='language'">http://www.w3.org/2001/XMLSchema#language</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='nmtoken'">http://www.w3.org/2001/XMLSchema#NMTOKEN</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='name'">http://www.w3.org/2001/XMLSchema#Name</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='ncname'">http://www.w3.org/2001/XMLSchema#NCName</xsl:when>
                        <xsl:otherwise>http://www.w3.org/2000/01/rdf-schema#Literal<xsl:message>
****ERROR****
The provided Datatype for (<xsl:value-of select="@name"/>) is not supported in OWL.
Instead Datatype xsd:Literal was taken as default.</xsl:message>						
                        </xsl:otherwise>
                        </xsl:choose>
						</xsl:for-each>
						
						
						</xsl:when>

                                                <xsl:otherwise>
                                                  <xsl:choose>
                                                    <xsl:when test="$idref='http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:000000000000087C'">http://www.w3.org/2001/XMLSchema#integer</xsl:when>
                                                    <xsl:when test="$idref='http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:000000000000087D'">http://www.w3.org/2001/XMLSchema#integer</xsl:when>
                                                    <xsl:when test="$idref='http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:0000000000000880'">http://www.w3.org/2001/XMLSchema#boolean</xsl:when>
                                                    <xsl:when test="$idref='http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:000000000000087E'">http://www.w3.org/2001/XMLSchema#string</xsl:when>
                                                    <xsl:otherwise>http://www.w3.org/2000/01/rdf-schema#Literal<xsl:message>
****ERROR****
The provided Datatype for (<xsl:value-of select="@name"/>) is not supported in OWL.
Instead Datatype xsd:Literal was taken as default.</xsl:message>		
                                                    </xsl:otherwise>
                                                  </xsl:choose>
                                                </xsl:otherwise>
                        
                        </xsl:choose>
					
					</xsl:attribute>
					
				<!-- end of rdfs:range -->					
				</xsl:element>
				
			<!-- end of owl:DatatypeProperty -->
			</xsl:element>
				
		</xsl:when>
				
		<!-- Class as value so class idref is not empty-->
		<xsl:when test="not($class_idref='')">	
					

					<!-- look for class which has given id -->
					<xsl:variable name="ref_class" select="//UML:Class[@xmi.id=$class_idref]" />
			
					<!-- save class name in variable -->
					<xsl:variable name="range_class" select="$ref_class/@name" />
			

					<!--create owl:ObjectProperty -->
					<xsl:element name="owl:ObjectProperty">
			
					<!--create attribute with property name -->
					<xsl:attribute name="rdf:ID"><xsl:value-of select="@name" /></xsl:attribute>
					
					<!-- create domain element -->
					<xsl:element name="rdfs:domain">
				
						<!-- create class element -->
						<xsl:element name="owl:Class">				
							<!-- create unionOf element -->
							<xsl:element name="owl:unionOf">				
								<!-- create parseType attribute with value Collection -->
								<xsl:attribute name="rdf:parseType">Collection</xsl:attribute>
																		
									<!-- search for every class that has current attribute to add to the collection -->
									<xsl:for-each select="//UML:Class">					
										<!-- if current attribute name is equal to one of the current class -->
										<xsl:if test="UML:Classifier.feature/UML:Attribute/@name=$attribute_name_of_key">					
											<!-- write class element -->
											<xsl:element name="owl:Class">					
												<!-- and add class name to collection -->
												<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"></xsl:value-of></xsl:attribute>					
											</xsl:element>					
										</xsl:if>					
									</xsl:for-each>
									<!-- do the same for associationClasses -->
									<!-- search for every class that has current attribute to add to the collection -->
									<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass">					
										<!-- if current attribute name is equal to one of the current class -->
										<xsl:if test="UML:Classifier.feature/UML:Attribute/@name=$attribute_name_of_key">					
											<!-- write class element -->
											<xsl:element name="owl:Class">					
												<!-- and add class name to collection -->
												<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"></xsl:value-of></xsl:attribute>					
											</xsl:element>					
										</xsl:if>					
									</xsl:for-each>
				
							<!-- end UnionOf -->
							</xsl:element>
					
						<!-- end class element -->
						</xsl:element>
												
					<!-- end domain element -->
					</xsl:element>
				
				<!-- create range of property -->
				<xsl:for-each select="//UML:Class[@xmi.id=$class_idref]">
				<xsl:element name="rdfs:range">						
					<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/>
					</xsl:attribute>					
				<!-- end of rdfs:range -->					
				</xsl:element>
				</xsl:for-each>
				
			<!-- end of owl:ObjectProperty -->
			</xsl:element>			
		<!-- end of class_idref check -->							
		</xsl:when>
		
		
		
		<!-- AssociationClass as value so class idref is not empty-->
		<xsl:when test="not($AC_idref='')">	
					
					<!-- look for class which has given id -->
					<xsl:variable name="ref_class" select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$class_idref]" />
			
					<!-- save class name in variable -->
					<xsl:variable name="range_class" select="$ref_class/@name" />
			
					<!--create owl:ObjectProperty -->
					<xsl:element name="owl:ObjectProperty">
			
					<!--create attribute with property name -->
					<xsl:attribute name="rdf:ID"><xsl:value-of select="@name" /></xsl:attribute>
					
					<!-- create domain element -->
					<xsl:element name="rdfs:domain">
				
						<!-- create class element -->
						<xsl:element name="owl:Class">				
							<!-- create unionOf element -->
							<xsl:element name="owl:unionOf">				
								<!-- create parseType attribute with value Collection -->
								<xsl:attribute name="rdf:parseType">Collection</xsl:attribute>
																		
									<!-- search for every class that has current attribute to add to the collection -->
									<xsl:for-each select="//UML:Class">					
										<!-- if current attribute name is equal to one of the current class -->
										<xsl:if test="UML:Classifier.feature/UML:Attribute/@name=$attribute_name_of_key">					
											<!-- write class element -->
											<xsl:element name="owl:Class">					
												<!-- and add class name to collection -->
												<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"></xsl:value-of></xsl:attribute>					
											</xsl:element>					
										</xsl:if>					
									</xsl:for-each>
									<!-- do the same for associationClasses -->
									<!-- search for every class that has current attribute to add to the collection -->
									<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass">					
										<!-- if current attribute name is equal to one of the current class -->
										<xsl:if test="UML:Classifier.feature/UML:Attribute/@name=$attribute_name_of_key">					
											<!-- write class element -->
											<xsl:element name="owl:Class">					
												<!-- and add class name to collection -->
												<xsl:attribute name="rdf:about">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"></xsl:value-of></xsl:attribute>					
											</xsl:element>					
										</xsl:if>					
									</xsl:for-each>
				
							<!-- end UnionOf -->
							</xsl:element>
					
						<!-- end class element -->
						</xsl:element>
												
					<!-- end domain element -->
					</xsl:element>
				
				<!-- create range of property -->
				<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$AC_idref]">
				<xsl:element name="rdfs:range">						
					<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/>
					</xsl:attribute>					
				<!-- end of rdfs:range -->					
				</xsl:element>
				</xsl:for-each>
				
			<!-- end of owl:ObjectProperty -->
			</xsl:element>			
		<!-- end of AC_idref check -->							
		</xsl:when>
						
   </xsl:choose>
  
<!-- end of ObjectProperty or DatatypeProperty decision -->			
</xsl:template>



<!-- ############################# -->
<!-- template for adding ObjectProperties which are unnamed  and bidirectional-->
<!-- ############################# -->	

<xsl:template name="unnamed_ObjectProperties">
<xsl:param name="association_name" />
<xsl:param name="association_xmi.id" />
<xsl:param name="domain" />
<xsl:param name="domain_AC" />
<xsl:param name="range_class" />
<xsl:param name="range_AC" />
<xsl:param name="range_interface" />
<xsl:param name="class_domain_idref" />
<xsl:param name="class_range_idref" />
<xsl:param name="class_range_AC_idref" />
<xsl:param name="interface_range_idref"/>
<xsl:param name="is_navigable1" />
<xsl:param name="is_navigable2" />
<xsl:param name="role_name1" />
<xsl:param name="role_name2" />


<!-- if association is not an aggregation/composition -->
<xsl:if test="//UML:Association[@xmi.id=$association_xmi.id]/UML:Association.connection/UML:AssociationEnd[1]/@aggregation='none' ">

<!--  then add ObjectProperty with name made up from ID -->
<xsl:choose>

	<!-- if association name is empty and association is bidirectional -->
	<xsl:when test="$association_name='' and $is_navigable1='true' and $is_navigable2='true'">
	

		<!-- add ObjectProperty using last 4 characters of the xmi.id string as name-->
		<xsl:element name="owl:ObjectProperty">
			<!--<xsl:attribute name="rdf:ID"><xsl:value-of select="substring($association_xmi.id,24,4)" /></xsl:attribute>-->
                        <xsl:attribute name="rdf:ID">inverseOf_<xsl:call-template name="getPropertyId"><xsl:with-param name="association_xmi.id"><xsl:value-of select="$association_xmi.id"/></xsl:with-param></xsl:call-template></xsl:attribute>
			<xsl:for-each select="//UML:Class[@name=$domain]">
			<xsl:element name="rdfs:range">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$domain" /></xsl:attribute>
			</xsl:element>			
			</xsl:for-each>
						
			<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@name=$domain_AC]">
			<xsl:element name="rdfs:range">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$domain_AC" /></xsl:attribute>
			</xsl:element>
			</xsl:for-each>
			
			<xsl:for-each select="//UML:Class[@name=$range_class]">
			<xsl:element name="rdfs:domain">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$range_class" /></xsl:attribute>
			</xsl:element>
			</xsl:for-each>
		
			<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@name=$range_AC]">
			<xsl:element name="rdfs:domain">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$range_AC" /></xsl:attribute>
			</xsl:element>
			</xsl:for-each>

			<!--<xsl:element name="owl:inverseOf">-->
				<!--<xsl:attribute name="rdf:resource">#inverseOf_<xsl:value-of select="substring($association_xmi.id,24,4)" /></xsl:attribute>-->
                        <xsl:element name="owl:inverseOf">
                              <xsl:attribute name="rdf:resource">#<xsl:call-template name="getPropertyId"><xsl:with-param name="association_xmi.id"><xsl:value-of select="$association_xmi.id"/></xsl:with-param></xsl:call-template></xsl:attribute>
                        </xsl:element>
			<!--</xsl:element>-->
		</xsl:element>
		
			
		<!-- add inverseOf Property using inverseOf_ prefix, switch domain and range -->
		<xsl:element name="owl:ObjectProperty">
			<!--<xsl:attribute name="rdf:ID">inverseOf_<xsl:value-of select="substring($association_xmi.id,24,4)" /></xsl:attribute>-->
			
                        <xsl:attribute name="rdf:ID"><xsl:call-template name="getPropertyId"><xsl:with-param name="association_xmi.id"><xsl:value-of select="$association_xmi.id"/></xsl:with-param></xsl:call-template></xsl:attribute>
			<xsl:for-each select="//UML:Class[@name=$range_class]">
			<xsl:element name="rdfs:range">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$range_class" /></xsl:attribute>
			</xsl:element>			
			</xsl:for-each>

			
			<xsl:for-each select="//UML:Class[@name=$domain]">
			<xsl:element name="rdfs:domain">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$domain" /></xsl:attribute>
			</xsl:element>
			</xsl:for-each>
			
			<!-- otherwise an associationClass is range -->
			<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@name=$domain_AC]">
			<xsl:element name="rdfs:domain">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$domain_AC" /></xsl:attribute>
			</xsl:element>			
			</xsl:for-each>

			<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@name=$range_AC]">
			<xsl:element name="rdfs:range">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$range_AC" /></xsl:attribute>
			</xsl:element>			
			</xsl:for-each>

			
                         <xsl:element name="owl:inverseOf">
                            <xsl:attribute name="rdf:resource">#inverseOf_<xsl:call-template name="getPropertyId"><xsl:with-param name="association_xmi.id"><xsl:value-of select="$association_xmi.id"/></xsl:with-param></xsl:call-template></xsl:attribute>
                         </xsl:element>
                  </xsl:element>

		
	<!-- enf of unnamed association -->	
	</xsl:when>	
	
	
	<!-- if association name is empty and association is unidirectional -->
	<xsl:when test="$association_name='' and $is_navigable1='false' and $is_navigable2='true'">

		<!-- add ObjectProperty using last 4 characters of the xmi.id string as name-->
		<xsl:element name="owl:ObjectProperty">
                        <xsl:attribute name="rdf:ID">inverseOf_<xsl:call-template name="getPropertyId"><xsl:with-param name="association_xmi.id"><xsl:value-of select="$association_xmi.id"/></xsl:with-param></xsl:call-template></xsl:attribute>
			<!-- if domain is a normal class, then it is added as domain -->
			<xsl:for-each select="//UML:Class[@name=$domain]">
			<xsl:element name="rdfs:range">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$domain" /></xsl:attribute>
			</xsl:element>		
			</xsl:for-each>									
													
			<!-- otherwise there was no domain added and domain can be an associationClass, so test this: -->
			<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@name=$domain_AC]">
 			<xsl:element name="rdfs:range">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$domain_AC" /></xsl:attribute>
			</xsl:element>		
			</xsl:for-each>
			<!-- now a domain is added. either with a normal class or with an associationClass -->
			
			
			<xsl:choose>
			

			<xsl:when test="not($class_range_idref='')">


							<!-- search this specific class -->
							<xsl:for-each select="//UML:Class[@xmi.id=$class_range_idref]">							
								<!-- write class element -->
								<xsl:element name="rdfs:domain">					
									<!-- and add class name to collection -->
									<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"></xsl:value-of></xsl:attribute>					
								</xsl:element>						
							</xsl:for-each>	
							
			</xsl:when>

		        <xsl:when test="not($class_range_AC_idref='')">
							
							<!-- otherwise it is an associationClass -->
							<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$class_range_AC_idref]">							
								<!-- write class element -->
								<xsl:element name="rdfs:domain">					
									<!-- and add class name to collection -->
									<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"></xsl:value-of></xsl:attribute>					
								</xsl:element>							
							</xsl:for-each>				
			</xsl:when>

			<xsl:when test="not($interface_range_idref='')">

							<!-- search this specific class -->
							<xsl:for-each select="//UML:Interface[@xmi.id=$interface_range_idref]">
							
								<!-- write class element -->
								<xsl:element name="rdfs:domain">
					
									<!-- and add class name to collection -->
									<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"></xsl:value-of></xsl:attribute>
					
								</xsl:element>
							<!-- end of search for class -->
							</xsl:for-each>	
			</xsl:when>

		</xsl:choose>	

                     <xsl:element name="owl:inverseOf">
                         <xsl:attribute name="rdf:resource">#<xsl:call-template name="getPropertyId"><xsl:with-param name="association_xmi.id"><xsl:value-of select="$association_xmi.id"/></xsl:with-param></xsl:call-template></xsl:attribute>
                     </xsl:element>
		
		<!-- end of owl:ObjectProperty -->	
		</xsl:element>
		
		<!-- add inverseOf Property using inverseOf_ prefix, switch domain and range -->
		<xsl:element name="owl:ObjectProperty">
                        
                        <xsl:attribute name="rdf:ID"><xsl:call-template name="getPropertyId"><xsl:with-param name="association_xmi.id"><xsl:value-of select="$association_xmi.id"/></xsl:with-param></xsl:call-template></xsl:attribute>
			<xsl:for-each select="//UML:Class[@name=$range_class]">
			<xsl:element name="rdfs:range">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$range_class" /></xsl:attribute>
			</xsl:element>		
			</xsl:for-each>	
			
			<xsl:for-each select="//UML:Class[@name=$domain]">
			<xsl:element name="rdfs:domain">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$domain" /></xsl:attribute>
			</xsl:element>
			</xsl:for-each>

			<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@name=$domain_AC]">
 			<xsl:element name="rdfs:domain">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$domain_AC" /></xsl:attribute>
			</xsl:element>		
			</xsl:for-each>

			<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@name=$range_AC]">
 			<xsl:element name="rdfs:range">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="$range_AC" /></xsl:attribute>
			</xsl:element>		
			</xsl:for-each>		
			
                        <xsl:element name="owl:inverseOf">
                             <xsl:attribute name="rdf:resource">#inverseOf_<xsl:call-template name="getPropertyId"><xsl:with-param name="association_xmi.id"><xsl:value-of select="$association_xmi.id"/></xsl:with-param></xsl:call-template></xsl:attribute>
                        </xsl:element>
		</xsl:element>	
		
	<!-- enf of unnamed unidirectional association -->	
	</xsl:when>	
	
  </xsl:choose>
	


		
	


</xsl:if>



<!-- end of template for adding ObjectProperties-->
</xsl:template>




<!-- ############################# -->
<!-- template for adding ObjectProperties to classes -->
<!-- ############################# -->	
	
<xsl:template name="add_ObjectProperty_toClass">
<xsl:param name="association_name" />
<xsl:param name="class_name"/>
<xsl:param name="association_id" />
<xsl:param name="lower" />
<xsl:param name="upper" />
<xsl:param name="is_navigable1" />
<xsl:param name="is_navigable2" />
<xsl:param name="role_name1" />


<!-- if association is unnamed then link to created name from association ID -->
<xsl:choose>
	
	<!-- only if association is unnamed and bidirectional -->
   <xsl:when test="$association_name='' and $is_navigable1='true' and $is_navigable2='true'">

     <xsl:element name="rdfs:subClassOf">
		<xsl:element name="owl:Restriction">
			<xsl:element name="owl:onProperty">
			
				<xsl:choose>
					<xsl:when test="//UML:Association[@xmi.id=$association_id]/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate'] or //UML:Association[@xmi.id=$association_id]/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite']">
                                                <xsl:attribute name="rdf:resource">#consists_of</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
                                                <xsl:attribute name="rdf:resource">#<xsl:call-template name="getPropertyId"><xsl:with-param name="association_xmi.id"><xsl:value-of select="$association_id"/></xsl:with-param></xsl:call-template></xsl:attribute>
					</xsl:otherwise>			
				</xsl:choose>
				
			</xsl:element>		
			
			<!-- add multiplicity -->
			<xsl:call-template name="add_multiplicity_op">
				<xsl:with-param name="lower"><xsl:value-of select="$lower" /></xsl:with-param>
				<xsl:with-param name="upper"><xsl:value-of select="$upper" /></xsl:with-param>			
			</xsl:call-template>
			
		</xsl:element>	
	</xsl:element>
  </xsl:when>
  
  
  	<!-- only if association is unnamed and unidirectional -->
   <xsl:when test="$association_name='' and $is_navigable1='false' and $is_navigable2='true'">

     <xsl:element name="rdfs:subClassOf">
		<xsl:element name="owl:Restriction">
			<xsl:element name="owl:onProperty">	
			
				<xsl:choose>
					<xsl:when test="//UML:Association[@xmi.id=$association_id]/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate'] or //UML:Association[@xmi.id=$association_id]/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite']">
                                                <xsl:attribute name="rdf:resource">#consists_of</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
                                                <xsl:attribute name="rdf:resource">#<xsl:call-template name="getPropertyId"><xsl:with-param name="association_xmi.id"><xsl:value-of select="$association_id"/></xsl:with-param></xsl:call-template></xsl:attribute>
					</xsl:otherwise>				
				</xsl:choose>
				
			</xsl:element>		
			
			<!-- add multiplicity -->
			<xsl:call-template name="add_multiplicity_op">
				<xsl:with-param name="lower"><xsl:value-of select="$lower" /></xsl:with-param>
				<xsl:with-param name="upper"><xsl:value-of select="$upper" /></xsl:with-param>			
			</xsl:call-template>
			
		</xsl:element>	
	</xsl:element>
  </xsl:when>
  
  <!-- if association has a name and is unidirectional-->
  <xsl:when test="$is_navigable1='false' and $is_navigable2='true'">
       <xsl:element name="rdfs:subClassOf">
		<xsl:element name="owl:Restriction">
			<xsl:element name="owl:onProperty">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="$association_name"/></xsl:attribute>
			</xsl:element>		

			<!-- add multiplicity -->
			<xsl:call-template name="add_multiplicity_op">
				<xsl:with-param name="lower"><xsl:value-of select="$lower" /></xsl:with-param>
				<xsl:with-param name="upper"><xsl:value-of select="$upper" /></xsl:with-param>			
			</xsl:call-template>
			
		</xsl:element>	
	</xsl:element>
	
  <!-- end if association has a name and is unidirectional -->
  </xsl:when>
  
<!-- if association has a name and is bidirectional-->
  <xsl:when test="$is_navigable1='true' and $is_navigable2='true'">
       <xsl:element name="rdfs:subClassOf">
		<xsl:element name="owl:Restriction">
			<xsl:element name="owl:onProperty">
				<xsl:attribute name="rdf:resource">#<xsl:value-of select="$association_name"/></xsl:attribute>
			</xsl:element>		

			<!-- add multiplicity -->
			<xsl:call-template name="add_multiplicity_op">
				<xsl:with-param name="lower"><xsl:value-of select="$lower" /></xsl:with-param>
				<xsl:with-param name="upper"><xsl:value-of select="$upper" /></xsl:with-param>			
			</xsl:call-template>
			
		</xsl:element>	
	</xsl:element>
	
  <!-- end if association has a name and is bidirectional -->
  </xsl:when>
  
</xsl:choose>


<!-- end of template for adding ObjectProperties to classes -->
</xsl:template>


<!-- ############################# -->
<!-- template for adding ObjectProperties inverseOf-->
<!-- ############################# -->	
	
<xsl:template name="add_ObjectProperty_toClass_inverseOf">
<xsl:param name="association_name" />
<xsl:param name="class_name"/>
<xsl:param name="association_id" />
<xsl:param name="lower" />
<xsl:param name="upper" />
<xsl:param name="is_navigable1" />
<xsl:param name="is_navigable2" />
<xsl:param name="role_name2" />


<xsl:choose>
	
<!-- add inverseOf when association is unnamed  create name from association ID -->
<xsl:when test="$association_name='' ">

	<xsl:element name="rdfs:subClassOf">
		<xsl:element name="owl:Restriction">
			<xsl:element name="owl:onProperty">
			
				<xsl:choose>
					<xsl:when test="//UML:Association[@xmi.id=$association_id]/UML:Association.connection/UML:AssociationEnd[1][@aggregation='aggregate'] or //UML:Association[@xmi.id=$association_id]/UML:Association.connection/UML:AssociationEnd[1][@aggregation='composite']">
                                               <xsl:attribute name="rdf:resource">#is_part_of</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
                                                <xsl:attribute name="rdf:resource">#inverseOf_<xsl:call-template name="getPropertyId"><xsl:with-param name="association_xmi.id"><xsl:value-of select="$association_id"/></xsl:with-param></xsl:call-template></xsl:attribute>
					</xsl:otherwise>				
				</xsl:choose>
				
			</xsl:element>		
			
			<!-- add multiplicity -->
			<xsl:call-template name="add_multiplicity_op">
				<xsl:with-param name="lower"><xsl:value-of select="$lower" /></xsl:with-param>
				<xsl:with-param name="upper"><xsl:value-of select="$upper" /></xsl:with-param>
			
			</xsl:call-template>
			
		</xsl:element>	
	</xsl:element>

</xsl:when>

<!-- add inverseOf when association is named. create name from association ID -->
<xsl:when test="not($association_name='') ">

	<xsl:element name="rdfs:subClassOf">
		<xsl:element name="owl:Restriction">
			<xsl:element name="owl:onProperty">
				<xsl:attribute name="rdf:resource">#inverseOf_<xsl:value-of select="$association_name"/></xsl:attribute>
			</xsl:element>		
			
			<!-- add multiplicity -->
			<xsl:call-template name="add_multiplicity_op">
				<xsl:with-param name="lower"><xsl:value-of select="$lower" /></xsl:with-param>
				<xsl:with-param name="upper"><xsl:value-of select="$upper" /></xsl:with-param>
			
			</xsl:call-template>
			
		</xsl:element>	
	</xsl:element>

</xsl:when>
</xsl:choose>



<!-- end of template for adding ObjectProperties inverseOf to classes -->
</xsl:template>




<!-- ############################# -->
<!-- template for adding multiplicties for ObjectProperties -->
<!-- ############################# -->	

<xsl:template name="add_multiplicity_op">
<xsl:param name="lower" />
<xsl:param name="upper"/>

<xsl:choose>
		
		<!-- if multiplicity is some number, then lower has to be equal to upper mulitplicity -->
		<xsl:when test="$lower&gt;0 and $lower=$upper">		
		
			<!-- add cardinality element with cardinality of 1 -->
			<xsl:element name="owl:cardinality">
			
				<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:attribute><xsl:value-of select="$lower" /></xsl:element>
		</xsl:when>

		<!-- if multiplicity is 0..1 -->
		<xsl:when test="$lower=0 and $upper=1">
		
			<!-- add maxCardinality of 1 -->
			
			<xsl:element name="owl:maxCardinality">
				<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:attribute>1</xsl:element>		
		
		</xsl:when>
		
		<!-- if multiplicity is 1..* -->
		<xsl:when test="$lower=1 and $upper=-1">
		
			<!-- add minCardinality of 1 -->
			<xsl:element name="owl:minCardinality">
				<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:attribute>1</xsl:element>
		
		</xsl:when>
		
		<!-- if multiplicity is 0..* -->
		<xsl:when test="$lower=0 and $upper=-1">
		
			<!-- add minCardinality of 0 -->
			<xsl:element name="owl:minCardinality">
				<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:attribute>0</xsl:element>
		
		</xsl:when>

		<!-- if multiplicity is 0..{Value} -->
		<xsl:when test="$lower=0 and $upper&gt;1">
		
			<!-- add maxCardinality of $upper-->
			<xsl:element name="owl:maxCardinality">
				<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:attribute><xsl:value-of select="$upper" /></xsl:element>
		
		</xsl:when>
		
		<!-- if multiplicity is 1..{Value} -->
		<xsl:when test="$lower=1 and $upper&gt;1">
		
			<!-- add minCardinality of 1-->
			<xsl:element name="owl:minCardinality">
				<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:attribute>1</xsl:element>
		
			<!-- add maxCardinality of $upper-->
			<xsl:element name="owl:maxCardinality">
				<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:attribute><xsl:value-of select="$upper" /></xsl:element>
		
		</xsl:when>
		
		<!-- if multiplicity is {Value}..* -->
		<xsl:when test="$lower&gt;1 and $upper=-1">
		
			<!-- add minCardinality of $lower-->
			<xsl:element name="owl:minCardinality">
				<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:attribute><xsl:value-of select="$lower" /></xsl:element>
		
		</xsl:when>

		<!-- if multiplicity is {Value}..{Value} -->
		<xsl:when test="$lower&gt;1 and $upper&gt;1 and $upper&gt;$lower">
		
			<!-- add minCardinality of $lower-->
			<xsl:element name="owl:minCardinality">
				<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:attribute><xsl:value-of select="$lower" /></xsl:element>
		
			<!-- add maxCardinality of $upper-->
			<xsl:element name="owl:maxCardinality">
				<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:attribute><xsl:value-of select="$upper" /></xsl:element>
		
		</xsl:when>

		<!-- if multiplicity is * do nothing, because there is no cardinality restricion-->		
		<xsl:otherwise>
	
			<xsl:element name="owl:someValuesFrom">			
				<xsl:attribute name="rdf:resource">http://www.w3.org/2002/07/owl#Thing</xsl:attribute></xsl:element>	
				
		</xsl:otherwise>
		
	</xsl:choose>	

<!-- end of template for multiplicites of ObjectProperties -->
</xsl:template>


	
	
<!-- ############################# -->
<!-- template for adding multiplicties for DatatypeProperties -->
<!-- ############################# -->	
	
<xsl:template name="add_multiplicity">



	<!-- looking for the attribute element which has the same name as given attribute name -->
	<!-- <xsl:for-each select="$attribute">-->
	
	
	
		<xsl:variable name="lower" select="../../UML:StructuralFeature.multiplicity/UML:Multiplicity/UML:Multiplicity.range/UML:MultiplicityRange/@lower" />
		<xsl:variable name="upper" select="../../UML:StructuralFeature.multiplicity/UML:Multiplicity/UML:Multiplicity.range/UML:MultiplicityRange/@upper" />
		
	<xsl:choose>

		<!-- if multiplicity is 0..1 -->
		<xsl:when test="$lower=0 and $upper=1">
		
			<!-- add maxCardinality of 1 -->
			
			<xsl:element name="owl:maxCardinality">
				<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:attribute>1</xsl:element>		
		
		</xsl:when>
		
		<!-- if multiplicity is 1..* -->
		<xsl:when test="$lower=1 and $upper=-1">
		
			<!-- add minCardinality of 1 -->
			<xsl:element name="owl:minCardinality">
				<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:attribute>1</xsl:element>
		
		</xsl:when>
		
		<!-- if multiplicity is 0..* -->
		<xsl:when test="$lower=0 and $upper=-1">
		
			<!-- add minCardinality of 0 -->
			<xsl:element name="owl:minCardinality">
				<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:attribute>0</xsl:element>
		
		</xsl:when>


		<!-- if multiplicity is 1 -->		
		<xsl:otherwise>
	
			<!-- add cardinality element with cardinality of 1 -->
			<xsl:element name="owl:cardinality">
				<xsl:attribute name="rdf:datatype">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:attribute>1</xsl:element>
				
		</xsl:otherwise>
		
	</xsl:choose>	
	

	
	<!-- end of looking for attribute to specified class -->
	<!-- </xsl:for-each> -->

<!-- end of template for multiplicities -->		
</xsl:template>	


<!-- ############################# -->
<!-- template for adding DatatypeProperties to classes and their multiplicities-->
<!-- ############################# -->

<xsl:template name="add_Property_toClass">


	<!-- adding DatatypeProperty to class which called this template -->
	<xsl:element name="rdfs:subClassOf">
		<xsl:element name="owl:Restriction">
				<xsl:element name="owl:onProperty">
					<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" /></xsl:attribute>
									
				<!-- end of owl:onProperty -->
				</xsl:element>				

								<!-- call template to add multiplicities of datatypeProperty of current class -->
				<xsl:call-template name="add_multiplicity">
				</xsl:call-template>	
				
                        <!--<xsl:for-each select="$attribute">-->

			<!--<xsl:sort select="@name" order="descending" />-->
			
			<!-- save current attribute name in variable -->
			<xsl:variable name="attribute_name_of_key" select="@name" />
			
			<!-- id of the class the attribute is referring to -->
			<xsl:variable name="class_idref" select="../../UML:StructuralFeature.type/UML:Class/@xmi.idref" />	
					
			<!-- id of the associationClass the attribute is referring to -->
			<xsl:variable name="AC_idref" select="../../UML:StructuralFeature.type/UML:AssociationClass/@xmi.idref" />	
	
			<!-- id of the Datatype the attribute is referring to -->
			<xsl:variable name="idref" select="../../UML:StructuralFeature.type/UML:DataType/@href" />	
				
                        <!-- if there is a class which has stereotype Datatyp then save it -->
                        <xsl:variable name="class_toCheck_stereotype" select="//UML:Class[@xmi.id=$class_idref]" />
                        <xsl:variable name="stereotype_idref" select="$class_toCheck_stereotype/UML:ModelElement.stereotype/UML:Stereotype/@xmi.idref" />
                        <xsl:variable name="stereotype_name" select="//UML:Stereotype[@xmi.id=$stereotype_idref]/@name" />

			<!-- look for class which has given id if it exists -->
			<xsl:variable name="ref_class" select="//UML:Class[@xmi.id=$class_idref]" />			
							
			<!-- then save class name in variable -->
		        <xsl:variable name="range_class" select="$ref_class/@name" />
				
                        <!-- decide wether attribute has DataType or Class as value-->
			<xsl:choose>			
			
				<!-- Datatype as value so idref is not empty or stereotype=DataType or DataType is from java.lang-->
				<xsl:when test="string-length($idref)!=0 or $stereotype_name='DataType' or $range_class='String' or $range_class='Time' or $range_class='Short' or $range_class='Long' or $range_class='Float' or $range_class='Double' or $range_class='Date' or $range_class='Character' or $range_class='Byte' or $range_class='Boolean' or $range_class='Integer' or $range_class='URL' ">
					
				
				<!-- create onDataRange -->
				<xsl:element name="owl:onDataRange">		
				
					<xsl:attribute name="rdf:resource">
					
					<!-- choose, if range is an int or string or binary and so on and write correct URI as resource -->
					<xsl:choose>		
					
						<!-- if range is not a normal datatype but a class with stereotype dataype then add this class as range -->
						<xsl:when test="$stereotype_name='DataType' or $range_class='String' or $range_class='Time' or $range_class='Short' or $range_class='Long' or $range_class='Float' or $range_class='Double' or $range_class='Date' or $range_class='Character' or $range_class='Byte' or $range_class='Boolean' or $range_class='Integer' or $range_class='URL' ">
						
						<xsl:for-each select="//UML:Class[@xmi.id=$class_idref]">
						<xsl:variable name="name"><xsl:value-of select="@name" /></xsl:variable>
						
						<xsl:choose>
						
		
						<xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='int'">http://www.w3.org/2001/XMLSchema#int</xsl:when>
						<xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='integer'">http://www.w3.org/2001/XMLSchema#integer</xsl:when>
						<xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='boolean'">http://www.w3.org/2001/XMLSchema#boolean</xsl:when>
						<xsl:when test="'real'=translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz') or
                            'number'=translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')or 
                            'double'=translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')">http://www.w3.org/2001/XMLSchema#double</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='float'">http://www.w3.org/2001/XMLSchema#float</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='binary'">http://www.w3.org/2001/XMLSchema#hexBinaray</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='string'">http://www.w3.org/2001/XMLSchema#string</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='char'">http://www.w3.org/2001/XMLSchema#string</xsl:when>                        
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='character'">http://www.w3.org/2001/XMLSchema#string</xsl:when>                        
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='time'">http://www.w3.org/2001/XMLSchema#time</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='datetime'">http://www.w3.org/2001/XMLSchema#datetime</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='date'">http://www.w3.org/2001/XMLSchema#date</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='short'">http://www.w3.org/2001/XMLSchema#short</xsl:when>                        
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='normalizedstring'">http://www.w3.org/2001/XMLSchema#normalizedString</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='nonnegativeinteger'">http://www.w3.org/2001/XMLSchema#nonNegativeInteger</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='positiveinteger'">http://www.w3.org/2001/XMLSchema#positiveInteger</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='nonpositiveinteger'">http://www.w3.org/2001/XMLSchema#nonPositiveInteger</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='negativeinteger'">http://www.w3.org/2001/XMLSchema#negativeInteger</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='long'">http://www.w3.org/2001/XMLSchema#long</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='byte'">http://www.w3.org/2001/XMLSchema#byte</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='unsignedlong'">http://www.w3.org/2001/XMLSchema#unsignedLong</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='unsignedint'">http://www.w3.org/2001/XMLSchema#unsignedInt</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='unsignedshort'">http://www.w3.org/2001/XMLSchema#unsignedShort</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='unsignedbyte'">http://www.w3.org/2001/XMLSchema#unsignedByte</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='heybinary'">http://www.w3.org/2001/XMLSchema#hexBinary</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ64','abcdefghijklmnopqrstuvwxyz64')='base64binary'">http://www.w3.org/2001/XMLSchema#bas64Binary</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='gyearmonth'">http://www.w3.org/2001/XMLSchema#gYearMonth</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='gyear'">http://www.w3.org/2001/XMLSchema#gYear</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='gmonthday'">http://www.w3.org/2001/XMLSchema#gMonthDay</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='gday'">http://www.w3.org/2001/XMLSchema#gDay</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='gmonth'">http://www.w3.org/2001/XMLSchema#gMonth</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='anyuri'">http://www.w3.org/2001/XMLSchema#anyURI</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='url'">http://www.w3.org/2001/XMLSchema#anyURI</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='uri'">http://www.w3.org/2001/XMLSchema#anyURI</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='token'">http://www.w3.org/2001/XMLSchema#token</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='language'">http://www.w3.org/2001/XMLSchema#language</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='nmtoken'">http://www.w3.org/2001/XMLSchema#NMTOKEN</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='name'">http://www.w3.org/2001/XMLSchema#Name</xsl:when>
                        <xsl:when test="translate($name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='ncname'">http://www.w3.org/2001/XMLSchema#NCName</xsl:when>
                        <xsl:otherwise>http://www.w3.org/2000/01/rdf-schema#Literal<xsl:message>
****ERROR****
The provided Datatype for (<xsl:value-of select="@name"/>) is not supported in OWL.
Instead Datatype xsd:Literal was taken as default.</xsl:message>						
                        </xsl:otherwise>
                        </xsl:choose>
						</xsl:for-each>
						
						
						</xsl:when>

                                                <xsl:otherwise>
                                                  <xsl:choose>
                                                    <xsl:when test="$idref='http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:000000000000087C'">http://www.w3.org/2001/XMLSchema#integer</xsl:when>
                                                    <xsl:when test="$idref='http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:000000000000087D'">http://www.w3.org/2001/XMLSchema#integer</xsl:when>
                                                    <xsl:when test="$idref='http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:0000000000000880'">http://www.w3.org/2001/XMLSchema#boolean</xsl:when>
                                                    <xsl:when test="$idref='http://argouml.org/profiles/uml14/default-uml14.xmi#-84-17--56-5-43645a83:11466542d86:-8000:000000000000087E'">http://www.w3.org/2001/XMLSchema#string</xsl:when>
                                                    <xsl:otherwise>http://www.w3.org/2000/01/rdf-schema#Literal<xsl:message>
****ERROR****
The provided Datatype for (<xsl:value-of select="@name"/>) is not supported in OWL.
Instead Datatype xsd:Literal was taken as default.</xsl:message>		
                                                    </xsl:otherwise>
                                                  </xsl:choose>
                                                </xsl:otherwise>
                        
                        </xsl:choose>
					
					</xsl:attribute>
					
				<!-- end of onDataRange -->					
				</xsl:element>
				
		</xsl:when>
			
		<!-- Class as value so class idref is not empty-->
		<xsl:when test="string-length($class_idref)!=0">	

				<!-- create range of property -->
				<xsl:for-each select="//UML:Class[@xmi.id=$class_idref]">
				<xsl:element name="owl:onClass">						
					<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/>
					</xsl:attribute>					
				<!-- end of rdfs:range -->					
				</xsl:element>
				</xsl:for-each>
						
		<!-- end of class_idref check -->							
		</xsl:when>

		<!-- AssociationClass as value so class idref is not empty-->
		<xsl:when test="string-length($AC_idref)!=0">					
				
				<!-- create range of property -->
				<xsl:for-each select="//UML:Namespace.ownedElement/UML:AssociationClass[@xmi.id=$AC_idref]">
				<xsl:element name="owl:onClass">						
					<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/>
					</xsl:attribute>					
				<!-- end of rdfs:range -->					
				</xsl:element>
				</xsl:for-each>
						
		<!-- end of AC_idref check -->							
		</xsl:when>
						
   </xsl:choose>

 <!--  </xsl:for-each>-->


		<!-- end of owl:Restriction -->
		</xsl:element>	
	<!-- end of rdfs:subClassOf -->
	</xsl:element>
		
</xsl:template>



<!-- ############################# -->
<!-- template for interface dependencies -->
<!-- ############################# -->

<xsl:template name="get_dependent_classes">
<xsl:param name="dependency_id" />

	<!-- check every dependency -->
	<xsl:for-each select="//UML:Namespace.ownedElement/UML:Abstraction">
	
		<!-- if dependency ID is equal to given dependency_id -->
		<xsl:if test="@xmi.id=$dependency_id">			
			
			<!-- then call template get_interface_name -->
			<xsl:call-template name="get_interface_name">
				<xsl:with-param name="interface_id"><xsl:value-of select="UML:Dependency.supplier/UML:Interface/@xmi.idref" /></xsl:with-param>			
			</xsl:call-template>
		</xsl:if>
		
	</xsl:for-each>

</xsl:template>


<!-- ####################### -->
<!-- template for generalization -->
<!-- ####################### -->

<!-- given id of generalization element, find id of parent class and call get_entity_name -->

<xsl:template name="get_parent">

  <!-- variable name with parent id from generalization-->
  <xsl:param name="generalization_id"/>
  
   <xsl:for-each select="//UML:Namespace.ownedElement/UML:Generalization"> 

	<!-- if ID of generlization element is equal with the ID of the given generalization ID -->
    <xsl:if test="@xmi.id=$generalization_id">
    
    <!-- then call template get_class_name -->
      <xsl:call-template name="get_class_name">
      <!-- with parameter ID of parent class -->
        <xsl:with-param name="class_id"><xsl:value-of select="UML:Generalization.parent/UML:Class/@xmi.idref"/></xsl:with-param>
      </xsl:call-template>
    </xsl:if>

  </xsl:for-each>
</xsl:template>

<!-- end of generalization template -->


<!-- ######################################   -->
<!-- template to get a specific class name to a given ID for inheriting-->
<!-- ####################################### -->

<xsl:template name="get_class_name">
  <xsl:param name="class_id"/>
  
  <!-- watch out for every class-->
  <xsl:for-each select="//UML:Class"> 

  <!-- check if class ID is equal to given class_id (which is parent class of generlization -->
  <xsl:if test="@xmi.id=$class_id">
  
  <!-- then add element rdfs:subClassOf with rdf:resource attribute specifying a name reference -->
      <xsl:element name="rdfs:subClassOf">
        <xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/>
        </xsl:attribute>
      </xsl:element>

  </xsl:if>
  </xsl:for-each>
</xsl:template>

<xsl:template name="createInterfaceParent">

  <!-- variable name with parent id from generalization-->
  <xsl:param name="generalization_id"/>
  
   <xsl:for-each select="//UML:Namespace.ownedElement/UML:Generalization"> 

	<!-- if ID of generlization element is equal with the ID of the given generalization ID -->
    <xsl:if test="@xmi.id=$generalization_id">
    
    <!-- then call template get_class_name -->
      <xsl:call-template name="get_interface_name">
      <!-- with parameter ID of parent class -->
        <xsl:with-param name="interface_id"><xsl:value-of select="UML:Generalization.parent/UML:Interface/@xmi.idref"/></xsl:with-param>
      </xsl:call-template>
    </xsl:if>

  </xsl:for-each>
</xsl:template>

<!-- End of template get_class_name -->


<!-- ######################################   -->
<!-- template to get a specific interface (class) name to a given ID for inheriting-->
<!-- ####################################### -->

<xsl:template name="get_interface_name">
  <xsl:param name="interface_id"/>
  
 <xsl:choose>
	 <!--  is it an interface? -->
		<xsl:when test="not($interface_id='')">
		
			 <!-- watch out for every interface-->
			  <xsl:for-each select="//UML:Interface"> 

				  <!-- check if class ID is equal to given class_id (which is parent class of generlization -->
				  <xsl:if test="@xmi.id=$interface_id">
  
				  <!-- then add element rdfs:subClassOf with rdf:resource attribute specifying a name reference -->
				  <xsl:element name="rdfs:subClassOf">
					<xsl:attribute name="rdf:resource">#<xsl:value-of select="../../@name" />:<xsl:value-of select="@name"/>
					</xsl:attribute>
				  </xsl:element>

				  </xsl:if>
			  </xsl:for-each>		
		
		</xsl:when>
		
	
</xsl:choose>  

</xsl:template>

<!-- End of template get_interface_name -->


<xsl:template name="getPropertyId">
  <xsl:param name="association_xmi.id"/>

  <xsl:variable name="class1_xmi_idref"><xsl:value-of select="//UML:Association[@xmi.id=$association_xmi.id]/UML:Association.connection/UML:AssociationEnd[1]/UML:AssociationEnd.participant/UML:Class/@xmi.idref"/></xsl:variable>
  <xsl:variable name="association_class_1_xmi_idref"><xsl:value-of select="//UML:Association[@xmi.id=$association_xmi.id]/UML:Association.connection/UML:AssociationEnd[1]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref"/></xsl:variable>
  <xsl:variable name="class2_xmi_idref"><xsl:value-of select="//UML:Association[@xmi.id=$association_xmi.id]/UML:Association.connection/UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:Class/@xmi.idref"/></xsl:variable>
  <xsl:variable name="association_class_2_xmi_idref"><xsl:value-of select="//UML:Association[@xmi.id=$association_xmi.id]/UML:Association.connection/UML:AssociationEnd[2]/UML:AssociationEnd.participant/UML:AssociationClass/@xmi.idref"/></xsl:variable>

  <xsl:choose>  
    <xsl:when test="not($class1_xmi_idref='') and not($class2_xmi_idref='')">
       <xsl:variable name="class1_name"><xsl:value-of select="//UML:Class[@xmi.id=$class1_xmi_idref]/@name"/></xsl:variable>
       <xsl:variable name="class2_name"><xsl:value-of select="//UML:Class[@xmi.id=$class2_xmi_idref]/@name"/></xsl:variable>
       <xsl:value-of select="concat($class1_name,$class2_name)"/>
    </xsl:when>
    <xsl:when test="not($association_class_1_xmi_idref='') and not($class2_xmi_idref='')">
       <xsl:variable name="association_class_1_name"><xsl:value-of select="//UML:Namespace.ownedElement/UML:AssociationClass[$association_class_1_xmi_idref=@xmi.id]/@name"/></xsl:variable>
       <xsl:variable name="class2_name"><xsl:value-of select="//UML:Class[@xmi.id=$class2_xmi_idref]/@name"/></xsl:variable>
       <xsl:value-of select="concat($association_class_1_name,$class2_name)"/>
    </xsl:when>
    <xsl:when test="not($class1_xmi_idref='') and not($association_class_2_xmi_idref='')">
      <xsl:variable name="class1_name"><xsl:value-of select="//UML:Class[@xmi.id=$class1_xmi_idref]/@name"/></xsl:variable>
      <xsl:variable name="association_class_2_name"><xsl:value-of select="//UML:Namespace.ownedElement/UML:AssociationClass[$association_class_2_xmi_idref=@xmi.id]/@name"/></xsl:variable>
      <xsl:value-of select="concat($class1_name,$association_class_2_name)"/>
    </xsl:when>
  </xsl:choose> 

</xsl:template>

</xsl:stylesheet>