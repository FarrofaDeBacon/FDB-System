const fs = require("fs");
const file = "d:/STEEL/projetos/steel-server-resources/fdb-medic/ui-svelte/src/components/InspectionPanel.svelte";
let content = fs.readFileSync(file, "utf8");

const skeletonHtml = `
      {#if currentView === 'body-inspection'}
        <div class="body-inspection-view" style="display: flex; flex-direction: column; align-items: center; position: relative; height: 100%;">
          <div class="section-title" style="margin-bottom: 1vw;">
            <i class="fas fa-search"></i>
            <span>{translations?.ui_bodyInspection || 'BODY INSPECTION'}</span>
          </div>
          
          <div class="medic-details" style="position: relative; width: 100%; height: 35vw; transform: scale(0.9); margin-top: -2vw;">
            {#each ["head", "spine", "upper", "larm", "lhand", "rarm", "rhand", "lleg", "rleg", "lfoot", "rfoot", "lower"] as part}
              <div class="medic-{part}" style="position: absolute; cursor: pointer; transition: filter 0.2s;" 
                   on:click={() => inspectBodyPart(part)}
                   on:mouseenter={(e) => e.currentTarget.style.filter = 'brightness(1.5) drop-shadow(0 0 5px rgba(226, 199, 146, 0.8))'}
                   on:mouseleave={(e) => e.currentTarget.style.filter = 'none'}>
                <div class="medic-{part}-first {discoveredInjuries[part] ? (discoveredInjuries[part].bleedingLevel > 0 || discoveredInjuries[part].painLevel > 0 ? 'wounded-body-part' : '') : ''}" style="position: relative;">
                  <div class="body-part-icon" style="background-image: url(../assets/imgs/{part}.png); width: 100%; height: 100%; background-size: contain; background-repeat: no-repeat;"></div>
                  
                  {#if inspectedBones.has(part)}
                    <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); color: rgba(255,255,255,0.8); font-size: 0.8vw;">
                      {#if discoveredInjuries[part]}
                        <i class="fas fa-exclamation-triangle" style="color: {discoveredInjuries[part].bleedingLevel >= 7 || discoveredInjuries[part].painLevel >= 8 ? 'var(--status-critical)' : 'var(--status-medium)'}; text-shadow: 0 0 3px black;"></i>
                      {:else}
                        <i class="fas fa-check" style="color: var(--status-good); text-shadow: 0 0 3px black;"></i>
                      {/if}
                    </div>
                  {/if}
                </div>
              </div>
            {/each}
          </div>

          {#if selectedBone}
            <div style="width: 100%; background: rgba(0,0,0,0.4); padding: 1vw; border-radius: 0.5vw; border: 1px solid rgba(226,199,146,0.3); margin-top: 1vw;">
              <div style="color: var(--text-main); font-weight: bold; font-size: 0.8vw; border-bottom: 1px solid rgba(226,199,146,0.3); padding-bottom: 0.5vw; margin-bottom: 0.5vw;">
                {getBodyPartName(selectedBone).toUpperCase()} {translations?.ui_inspectionReport || 'INSPECTION REPORT'}
              </div>
              
              {#if detailedInspectionResults[selectedBone]}
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5vw; font-size: 0.6vw;">
                  <div><span style="color: #aaa;">{translations?.ui_boneIntegrity || 'Bone Integrity:'}</span> <span style="color: {detailedInspectionResults[selectedBone].boneIntegrity.includes('fracture') ? 'var(--status-critical)' : 'white'}">{detailedInspectionResults[selectedBone].boneIntegrity}</span></div>
                  <div><span style="color: #aaa;">{translations?.ui_softTissue || 'Soft Tissue:'}</span> <span style="color: white;">{detailedInspectionResults[selectedBone].softTissue}</span></div>
                  <div><span style="color: #aaa;">{translations?.ui_bloodFlow || 'Blood Flow:'}</span> <span style="color: {detailedInspectionResults[selectedBone].bloodFlow.includes('Active') ? 'var(--status-critical)' : 'white'}">{detailedInspectionResults[selectedBone].bloodFlow}</span></div>
                  <div><span style="color: #aaa;">{translations?.ui_painResponse || 'Pain Response:'}</span> <span style="color: {detailedInspectionResults[selectedBone].painResponse.includes('Severe') || detailedInspectionResults[selectedBone].painResponse.includes('8') ? 'var(--status-critical)' : 'white'}">{detailedInspectionResults[selectedBone].painResponse}</span></div>
                </div>
                
                <div style="margin-top: 0.5vw; padding-top: 0.5vw; border-top: 1px dashed rgba(226,199,146,0.2); font-size: 0.6vw;">
                  <span style="color: #aaa;">{translations?.ui_recommendation || 'Recommendation:'}</span> <span style="color: {detailedInspectionResults[selectedBone].recommendation.includes('URGENT') ? 'var(--status-critical)' : 'var(--status-good)'}">{detailedInspectionResults[selectedBone].recommendation}</span>
                </div>
              {:else}
                <div style="color: #888; font-size: 0.6vw; font-style: italic;">{translations?.ui_processingReport || 'Processing inspection data...'}</div>
              {/if}
            </div>
          {:else}
            <div style="color: #888; font-size: 0.7vw; font-style: italic; margin-top: 1vw;">
              {translations?.ui_selectBodyPartToInspect || 'Click on a body part to inspect for hidden injuries'}
            </div>
          {/if}
          
          {#if hasInspectedFully}
            <div style="margin-top: 1vw; color: var(--status-good); font-size: 0.6vw; font-weight: bold; background: rgba(39, 174, 96, 0.1); padding: 0.5vw 1vw; border-radius: 0.2vw; border: 1px solid rgba(39, 174, 96, 0.3);">
              <i class="fas fa-check-double"></i> {translations?.ui_fullBodyInspectionComplete || 'FULL BODY INSPECTION COMPLETE'}
            </div>
          {/if}
        </div>
      {/if}
`;

content = content.replace("{#if currentView === 'injection'}", skeletonHtml + "\n\n      {#if currentView === 'injection'}");

if (!content.includes("import '../assets/css/medpanel.css';")) {
  content = content.replace("import selectionBoxBg from '../assets/imgs/selection_box_bg_1d.png';", "import selectionBoxBg from '../assets/imgs/selection_box_bg_1d.png';\n  import '../assets/css/medpanel.css';");
}

fs.writeFileSync(file, content);
console.log("Done");
