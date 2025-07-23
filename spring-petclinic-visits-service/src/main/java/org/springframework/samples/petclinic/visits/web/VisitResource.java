package org.springframework.samples.petclinic.visits.web;

import java.util.List;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;

import io.micrometer.core.instrument.MeterRegistry;
import io.micrometer.core.instrument.Timer;
import io.micrometer.core.annotation.Timed;
import io.micrometer.core.annotation.Counted;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.samples.petclinic.visits.model.Visit;
import org.springframework.samples.petclinic.visits.model.VisitRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Timed("petclinic.visit")
class VisitResource {

    private static final Logger log = LoggerFactory.getLogger(VisitResource.class);

    private final VisitRepository visitRepository;
    private final MeterRegistry meterRegistry;

    VisitResource(VisitRepository visitRepository, MeterRegistry meterRegistry) {
        this.visitRepository = visitRepository;
        this.meterRegistry = meterRegistry;
    }

    @PostMapping("owners/*/pets/{petId}/visits")
    @ResponseStatus(HttpStatus.CREATED)
    public Visit create(
        @Valid @RequestBody Visit visit,
        @PathVariable("petId") @Min(1) int petId) {

        return Timer
            .builder("custom.petclinic.visit.create.latency")
            .description("Latency of create visit action")
            .register(meterRegistry)
            .record(() -> {
                visit.setPetId(petId);
                log.info("Saving visit {}", visit);
                return visitRepository.save(visit);
            });
    }

    @GetMapping("owners/*/pets/{petId}/visits")
    public List<Visit> read(@PathVariable("petId") @Min(1) int petId) {
        log.info("Finding visits for pet with id {}", petId);
        return visitRepository.findByPetId(petId);
    }

    @GetMapping("pets/visits")
    public Visits read(@RequestParam("petId") List<Integer> petIds) {
        final List<Visit> byPetIdIn = visitRepository.findByPetIdIn(petIds);
        log.info("Found {} visits for pet ids {}", byPetIdIn.size(), petIds); 
        return new Visits(byPetIdIn);
    }

    record Visits(
        List<Visit> items
    ) {
    }
}